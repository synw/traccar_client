import 'package:geopoint/geopoint.dart';

/// A class representing a device
class Device {
  /// Main constructor
  Device({this.id, this.deviceId, this.name, this.position, this.batteryLevel});

  /// The device database id
  final int id;

  /// The on device unique id
  final String deviceId;

  /// The device name
  String name;

  /// The device position
  DevicePosition position;

  /// The device battery level
  double batteryLevel;

  /// Create a device from json data
  Device.fromJson(Map<String, dynamic> data)
      : this.deviceId = data["deviceId"].toString(),
        this.id = int.parse(data["id"].toString()),
        this.position = DevicePosition.fromJson(data),
        this.batteryLevel =
            double.parse(data["attributes"]["batteryLevel"].toString()) {
    if (data.containsKey("name")) {
      this.name = data["name"].toString();
    }
  }

  @override
  String toString() {
    String _name = "$deviceId";
    if (name != null) {
      _name = name;
    }
    return "$_name: $position";
  }
}

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

  /// The data of the position
  final DateTime date;

  /// Create a position from json
  DevicePosition.fromJson(Map<String, dynamic> data)
      : this.id = int.parse(data["id"].toString()),
        this.geoPoint = GeoPoint(
            name: data["id"].toString(),
            latitude: double.parse(data["latitude"].toString()),
            longitude: double.parse(data["longitude"].toString()),
            speed: double.parse(data["speed"].toString()),
            accuracy: double.parse(data["accuracy"].toString()),
            altitude: double.parse(data["altitude"].toString())),
        this.distance = double.parse(data["attributes"]["distance"].toString()),
        this.totalDistance =
            double.parse(data["attributes"]["totalDistance"].toString()),
        this.address = data["address"].toString(),
        this.date = DateTime.parse(data["fixTime"].toString());

  @override
  String toString() {
    return "$date : ${geoPoint.latitude}, ${geoPoint.longitude}";
  }
}
