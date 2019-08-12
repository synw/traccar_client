import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'models.dart';

/// A class to handle the queries to the server
class TraccarQueries {
  /// Main constructor
  TraccarQueries(
      {@required this.cookie,
      @required this.serverUrl,
      @required this.verbose});

  /// The cookie used
  final String cookie;

  /// Print info at runtime
  final bool verbose;

  /// The server url
  final String serverUrl;

  final _dio = Dio();

  /// Get a device positions for a period of time
  Future<List<Device>> positions(
      {String protocol = "http",
      @required String deviceId,
      @required String from,
      @required String to}) async {
    assert(cookie != null, "The cookie is not set");
    String uri = "$protocol://$serverUrl/api/positions";
    if (verbose) {
      print("Query: $uri");
    }
    Response response;
    try {
      response = await _dio.get<dynamic>(
        uri,
        queryParameters: <String, dynamic>{
          "deviceId": int.parse("$deviceId"),
          "from": from,
          "to": to
        },
        options: Options(
          contentType: ContentType.json,
          headers: <String, dynamic>{
            "Cookie": cookie,
            "Accept": "application/json"
          },
        ),
      );
    } on DioError catch (e) {
      print("DIO ERROR:");
      if (e.response != null) {
        print("Response:");
        print("${e.response.data}");
        print("${e.response.headers}");
        print("${e.response.request}");
      } else {
        print("No response");
        print("${e.request.contentType}");
        print("${e.request.headers}");
        print("${e.message}");
      }
      rethrow;
    } catch (e) {
      throw ("ERROR $e");
    }
    final devices = <Device>[];
    for (final data in response.data) {
      devices.add(Device.fromJson(data as Map<String, dynamic>));
    }
    return devices;
  }
}
