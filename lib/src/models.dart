import 'package:geopoint/geopoint.dart';
import 'utils.dart';

/// A class representing a device
class Device {
  /// Main constructor
  Device(
      {this.id,
      this.uniqueId,
      this.groupId,
      this.name,
      this.position,
      this.batteryLevel,
      this.keepAlive = 1,
      this.isActive,
      this.isDisabled,
      this.properties = const <String, dynamic>{}});

  /// The device database id
  final int id;

  /// The on device unique id
  String uniqueId;

  /// The group of the device
  int groupId;

  /// The device name
  String name;

  /// The device position
  DevicePosition position;

  /// The device battery level
  double batteryLevel;

  /// Minutes a device is considered alive
  int keepAlive;

  /// The device can be disabled
  bool isDisabled;

  /// false if the device has never updated one position
  bool isActive;

  /// Extra properties for the device
  Map<String, dynamic> properties;

  /// Is the device online
  bool get isAlive => _isDeviceAlive();

  /// Create a device from json data
  Device.fromPosition(Map<String, dynamic> data,
      {String timeZoneOffset = "0", int keepAlive = 1})
      : this.keepAlive = keepAlive,
        this.id = int.parse(data["deviceId"].toString()),
        this.position =
            DevicePosition.fromJson(data, timeZoneOffset: timeZoneOffset),
        this.batteryLevel =
            double.parse(data["attributes"]["batteryLevel"].toString());

  bool _isDeviceAlive() {
    if (position == null) {
      return false;
    }
    final now = DateTime.now();
    final dateAlive = now.subtract(Duration(minutes: keepAlive));
    bool isAlive = false;
    if (position.date.isAfter(dateAlive)) {
      isAlive = true;
    }
    return isAlive;
  }

  /// Print a description of the device
  void describe() {
    print("Device:");
    print(" - id : $id");
    print(" - uniqueId : $uniqueId");
    print(" - name : $name");
    print(" - batteryLevel: $batteryLevel");
    print(" - position : $position");
  }

  @override
  String toString() {
    String _name = "$uniqueId";
    if (name != null) {
      _name = name;
    }
    String res;
    if (position != null) {
      res = "$_name: $position";
    } else {
      res = "$_name";
    }
    return res;
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

  /// The date of the position
  DateTime date;

  /// Create a position from json
  DevicePosition.fromJson(Map<String, dynamic> data,
      {String timeZoneOffset = "0"})
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
        this.address = data["address"].toString() {
    this.date = dateFromUtcOffset(data["fixTime"].toString(), timeZoneOffset);
  }

  @override
  String toString() {
    return "$date : ${geoPoint.latitude}, ${geoPoint.longitude}";
  }
}
