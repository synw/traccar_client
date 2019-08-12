import 'dart:async';
import 'dart:convert' as json;
import 'package:meta/meta.dart';
import 'package:web_socket_channel/io.dart';
import 'package:dio/dio.dart';
import 'models.dart';
import 'queries.dart';

/// The main class to handle device positions
class DevicesPositions {
  /// Provide a server url and a user token
  DevicesPositions(
      {@required this.serverUrl,
      @required this.userToken,
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
    await _getCookie();
    query =
        TraccarQueries(cookie: _cookie, serverUrl: serverUrl, verbose: verbose);
    _readyCompleter.complete();
  }

  /// Get the device positions
  Future<Stream<Device>> positions() async {
    if (verbose) {
      print("Setting up positions stream");
    }
    final posStream =
        await _positionsStream(serverUrl: serverUrl, userToken: userToken);
    _rawPosSub = posStream.listen((dynamic data) {
      final Map dataMap = json.jsonDecode(data.toString()) as Map;
      if (dataMap.containsKey("positions")) {
        if (_devicesMap.isNotEmpty) {
          DevicePosition pos;
          for (final posMap in dataMap["positions"]) {
            pos = DevicePosition.fromJson(posMap as Map<String, dynamic>);
            _devicesMap[pos.id].position = pos;
            _positions.sink.add(_devicesMap[pos.id]);
          }
        }
      } else {
        for (final d in dataMap["devices"]) {
          if (!_devicesMap.containsKey(d["id"])) {
            final id = int.parse(d["id"].toString());
            _devicesMap[id] = Device(
                id: id,
                deviceId: d["uniqueId"].toString(),
                name: d["name"].toString());
          }
        }
      }
    });
    return _positions.stream;
  }

  Future<void> _getCookie({String protocol = "http"}) async {
    final response = await _dio.get<dynamic>(
      "$protocol://$serverUrl/api/session?token=$userToken",
    );
    _cookie = response.headers["set-cookie"][0];
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
