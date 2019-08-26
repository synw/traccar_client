import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'models.dart';
import 'utils.dart';

/// A class to handle the queries to the server
class TraccarQueries {
  /// Main constructor
  TraccarQueries(
      {@required this.cookie,
      @required this.serverUrl,
      this.timeZoneOffset = "0",
      @required this.verbose});

  /// The cookie used
  final String cookie;

  /// Print info at runtime
  final bool verbose;

  /// The server url
  final String serverUrl;

  /// The timezone offset from utc
  final String timeZoneOffset;

  final _dio = Dio();

  /// Get a list of devices
  Future<List<Device>> devices({String protocol = "http"}) async {
    assert(cookie != null, "The cookie is not set");
    final uri = "$protocol://$serverUrl/api/devices";
    if (verbose) {
      print("Query: $uri");
    }
    final response = await _httpRequest(uri: uri);
    //print("RESP^${response.data}");
    final devices = <Device>[];
    for (final data in response.data) {
      final id = int.parse(data["id"].toString());
      final uniqueId = data["uniqueId"].toString();
      final name = data["name"].toString();
      final device = Device(id: id, uniqueId: uniqueId, name: name);
      //final date =
      //    dateFromUtcOffset(data["fixTime"].toString(), timeZoneOffset);
      devices.add(device);
    }
    if (verbose) {
      print("Found ${devices.length} devices");
    }
    return devices;
  }

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
    date ??= DateTime.now();
    final fromDate = date.subtract(since);
    final queryParameters = <String, dynamic>{
      "deviceId": int.parse("$deviceId"),
      "from": _formatDate(fromDate),
      "to": _formatDate(date)
    };
    final response = await _httpRequest(uri: uri, queryParams: queryParameters);
    final devices = <Device>[];
    for (final data in response.data) {
      devices.add(Device.fromPosition(data as Map<String, dynamic>,
          timeZoneOffset: timeZoneOffset));
    }
    return devices;
  }

  Future<Response> _httpRequest(
      {@required String uri,
      Map<String, dynamic> queryParams = const <String, dynamic>{}}) async {
    Response response;
    try {
      response = await _dio.get<dynamic>(
        uri,
        queryParameters: queryParams,
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
    return response;
  }

  String _formatDate(DateTime date) {
    final d = date.toIso8601String().split(".")[0];
    final l = d.split(":");
    return "${l[0]}:${l[1]}:00Z";
  }
}
