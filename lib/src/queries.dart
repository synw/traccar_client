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
      @required Duration since,
      String timeZoneOffset = "0",
      DateTime date}) async {
    assert(cookie != null, "The cookie is not set");
    final uri = "$protocol://$serverUrl/api/positions";
    if (verbose) {
      print("Query: $uri");
    }
    Response response;
    date ??= DateTime.now();
    final fromDate = date.subtract(since);
    print("${date.toIso8601String()} / $fromDate");
    try {
      response = await _dio.get<dynamic>(
        uri,
        queryParameters: <String, dynamic>{
          "deviceId": int.parse("$deviceId"),
          "from": _formatDate(fromDate),
          "to": _formatDate(date)
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
      devices.add(Device.fromJson(data as Map<String, dynamic>,
          timeZoneOffset: timeZoneOffset));
    }
    return devices;
  }

  String _formatDate(DateTime date) {
    final d = date.toIso8601String().split(".")[0];
    final l = d.split(":");
    return "${l[0]}:${l[1]}:00Z";
  }
}
