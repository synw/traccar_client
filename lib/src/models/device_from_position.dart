import 'package:device/device.dart';
import 'position.dart';

/// Get a device from a traccar position
Device deviceFromPosition(Map<String, dynamic> data,
    {String timeZoneOffset = "0",
    Duration keepAlive = const Duration(minutes: 1)}) {
  return Device(
      id: int.parse(data["deviceId"].toString()),
      keepAlive: keepAlive,
      position: DevicePosition.fromJson(data, timeZoneOffset: timeZoneOffset)
          .geoPoint,
      batteryLevel:
          double.parse(data["attributes"]["batteryLevel"].toString()));
}
