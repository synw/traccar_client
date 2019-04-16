import 'dart:async';
import 'dart:convert' as json;
import 'package:web_socket_channel/io.dart';
import 'package:dio/dio.dart';
import 'models.dart';

class DevicesPositions {
  DevicesPositions({this.serverUrl, this.userToken})
      : assert(serverUrl != null),
        assert(userToken != null);

  final String serverUrl;
  final String userToken;

  final _dio = Dio();
  Map<int, Device> _devicesMap = {};
  StreamSubscription _rawPosSub;
  final _positions = StreamController<Device>.broadcast();

  void dispose() {
    _rawPosSub.cancel();
  }

  Future<Stream<dynamic>> _positionsStream(
      {String serverUrl, String userToken, String protocol = "http"}) async {
    Response response = await _dio.get(
      "$protocol://$serverUrl/api/session?token=$userToken",
    );
    var cookie = response.headers["set-cookie"][0];
    var channel = IOWebSocketChannel.connect("ws://$serverUrl/api/socket",
        headers: {"Cookie": cookie});
    return channel.stream;
  }

  Future<Stream<Device>> positions() async {
    var posStream =
        await _positionsStream(serverUrl: serverUrl, userToken: userToken);
    _rawPosSub = posStream.listen((data) {
      Map dataMap = json.jsonDecode(data);
      if (dataMap.containsKey("positions")) {
        if (_devicesMap.length > 0) {
          DevicePosition pos;
          for (var posMap in dataMap["positions"]) {
            pos = DevicePosition.fromJson(posMap);
            _devicesMap[pos.id].position = pos;
            _positions.sink.add(_devicesMap[pos.id]);
          }
        }
      } else {
        for (var d in dataMap["devices"]) {
          if (!_devicesMap.containsKey(d["id"]))
            _devicesMap[d["id"]] =
                Device(id: d["id"], deviceId: d["uniqueId"], name: d["name"]);
        }
      }
    });
    return _positions.stream;
  }
}
