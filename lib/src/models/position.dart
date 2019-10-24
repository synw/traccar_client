import 'package:geopoint/geopoint.dart';
import '../utils.dart';

/// A class to handle a device position
class DevicePosition {
  /// The position database id
  final int id;

  /// The geo data
  final GeoPoint geoPoint;

  /// The distance since previous point
  final double distance;

  /// The total distance for the device
  final double totalDistance;

  /// The address of the device position
  final String address;

  /// The date of the position
  DateTime date;

  /// Create a position from json
  DevicePosition.fromJson(Map<String, dynamic> data,
      {String timeZoneOffset = "0"})
      : this.id = int.parse(data["id"].toString()),
        this.geoPoint = GeoPoint(
            name: data["id"].toString(),
            timestamp:
                dateFromUtcOffset(data["fixTime"].toString(), timeZoneOffset)
                    .millisecondsSinceEpoch,
            latitude: double.parse(data["latitude"].toString()),
            longitude: double.parse(data["longitude"].toString()),
            speed: double.parse(data["speed"].toString()),
            accuracy: double.parse(data["accuracy"].toString()),
            altitude: double.parse(data["altitude"].toString())),
        this.distance = double.parse(data["attributes"]["distance"].toString()),
        this.totalDistance =
            double.parse(data["attributes"]["totalDistance"].toString()),
        this.address = data["address"].toString() {
    this.date = dateFromUtcOffset(data["fixTime"].toString(), timeZoneOffset);
  }

  @override
  String toString() {
    return "${date.hour}:${date.minute}:${date.second} " +
        ": ${geoPoint.latitude}, ${geoPoint.longitude}";
  }
}
