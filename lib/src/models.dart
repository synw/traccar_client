import 'package:latlong/latlong.dart';

class Device {
  Device({this.id, this.deviceId, this.name, this.position});

  final int id;
  final String deviceId;
  final String name;
  DevicePosition position;
}

class DevicePosition {
  final int id;
  final LatLng point;
  final double accuracy;
  final double altitude;
  final double speed;
  final double distance;
  final double totalDistance;
  final double batteryLevel;
  final String address;
  final DateTime date;

  DevicePosition.fromJson(Map data)
      : this.id = data["deviceId"],
        this.point = LatLng(data["latitude"], data["longitude"]),
        this.accuracy = data["accuracy"],
        this.altitude = data["altitude"],
        this.speed = data["speed"],
        this.distance = data["attributes"]["distance"],
        this.totalDistance = data["attributes"]["totalDistance"],
        this.batteryLevel = data["attributes"]["batteryLevel"],
        this.address = data["address"],
        this.date = DateTime.parse(data["fixTime"]);

  @override
  String toString() {
    return "$id : ${point.latitude}, ${point.longitude}, $date";
  }
}
