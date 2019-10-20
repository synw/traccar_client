import 'dart:async';
import 'dart:convert' as json;
import 'package:meta/meta.dart';
import 'package:web_socket_channel/io.dart';
import 'package:dio/dio.dart';
import 'models.dart';
import 'queries.dart';

/// The main class to handle device positions
class Traccar {
  /// Provide a server url and a user token
  Traccar(
      {@required this.serverUrl,
      @required this.userToken,
      this.keepAlive = 1,
      this.verbose = false})
      : assert(serverUrl != null),
        assert(userToken != null);

  /// Thre Traccar server url
  final String serverUrl;

  /// The user token
  final String userToken;

  /// Print info at runtime
  final bool verbose;

  /// The queries available
  TraccarQueries query;

  /// Minutes a device is considered alive
  int keepAlive;

  final _readyCompleter = Completer<Null>();

  final _dio = Dio();
  final _devicesMap = <int, Device>{};
  StreamSubscription<dynamic> _rawPosSub;
  final _positions = StreamController<Device>.broadcast();
  String _cookie;

  /// On ready callback
  Future get onReady => _readyCompleter.future;

  /// Run init before using the other methods
  Future<void> init() async {
    if (verbose) {
      print("Initializing Traccar cli");
    }
    await _getCookie();
    query =
        TraccarQueries(cookie: _cookie, serverUrl: serverUrl, verbose: verbose);
    if (verbose) {
      print("Traccar client initialized");
    }
    _readyCompleter.complete();
  }

  /// Get the device positions
  Future<Stream<Device>> positions() async {
    if (verbose) {
      print("Setting up positions stream");
    }
    final posStream =
        await _positionsStream(serverUrl: serverUrl, userToken: userToken);
    if (verbose) {
      print("Subscribing to positions stream");
    }
    _rawPosSub = posStream.listen((dynamic data) {
      print("DATA $data");
      final dataMap = json.jsonDecode(data.toString()) as Map<String, dynamic>;
      if (dataMap.containsKey("positions")) {
        if (verbose) {
          print("Device positions update:");
        }
        DevicePosition pos;
        for (final posMap in dataMap["positions"]) {
          //print("POS MAP $posMap");
          pos = DevicePosition.fromJson(posMap as Map<String, dynamic>);
          final id = posMap["deviceId"] as int;
          Device device;
          if (_devicesMap.containsKey(id)) {
            device = _devicesMap[id];
          } else {
            device = Device.fromPosition(posMap as Map<String, dynamic>,
                keepAlive: keepAlive);
          }
          device.position = pos;
          _devicesMap[id] = device;
          _positions.sink.add(device);
          if (verbose) {
            print(" - $pos");
          }
        }
      } else {
        for (final d in dataMap["devices"]) {
          if (verbose) {
            print("Devices update:");
          }
          if (!_devicesMap.containsKey(d["id"])) {
            final id = int.parse(d["id"].toString());
            d["name"] ??= d["id"].toString();
            final device = Device(id: id, name: d["name"].toString());
            _devicesMap[id] = device;
            //print(" - ${device.name}");
          }
        }
      }
    });
    return _positions.stream;
  }

  Future<void> _getCookie({String protocol = "http"}) async {
    final addr = "$protocol://$serverUrl/api/session";
    if (verbose) {
      print("Getting cookie at $addr");
    }
    dynamic response;
    try {
      response = await _dio.get<Map<String, dynamic>>(addr,
          queryParameters: <String, dynamic>{"token": userToken});
    } on DioError catch (e) {
      if (e.response != null) {
        print("STATUS: ${e.response?.statusCode}");
        print("DATA: ${e.response?.data}");
        print("HEADERS: ${e.response?.headers}");
        print("REQUEST: ${e.response?.request?.uri}");
      } else {
        print("STATUS: ${e?.response?.statusCode}");
        print("REQUEST: ${e.request.uri}");
        print("${e.request.receiveDataWhenStatusError}");
        print("MESSAGE: ${e.message}");
        rethrow;
      }
    } catch (e) {
      print("EX");
      print("STATUS: ${e?.response?.statusCode}");
      print("REQUEST: ${e?.request?.uri}");
      print("MESSAGE: ${e.message}");
    }
    _cookie = response.headers["set-cookie"][0].toString();
    if (verbose) {
      print("Cookie set: $_cookie");
    }
  }

  Future<Stream<dynamic>> _positionsStream(
      {String serverUrl, String userToken, String protocol = "http"}) async {
    if (_cookie == null) {
      await _getCookie();
    }
    final channel = IOWebSocketChannel.connect("ws://$serverUrl/api/socket",
        headers: <String, dynamic>{"Cookie": _cookie});
    return channel.stream;
  }

  /// Dispose if using the positions stream
  void dispose() {
    _rawPosSub.cancel();
  }
}
