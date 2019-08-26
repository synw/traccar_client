# Traccar client

Dart client for the Traccar geolocation server. Get real time devices positions updates from a
[Traccar](http://traccar.org/) server.

## Usage

   ```dart
   import 'package:traccar_client/traccar_client.dart';

   main() async {
      var updater = DevicesPositions(
         serverUrl: "127.0.0.1",
         userToken: "USER_TOKEN_HERE");
      var positions = await updater.positions();
      positions.listen((device) {
         print("Position update");
         print("${device.name}: ${device.position.point.latitude} / " +
            "${device.position.point.longitude}");
      });
   }
   ```

## Queries

Query for a list of devices:

   ```dart
   trac.query.devices().then((List<Device> devices) {
      print("$devices");
   });
   ```

## Data structure

The position stream outputs `Device` objects with updated positions:

   ```dart
   class Device {
     final int id;
     String uniqueId;
     int groupId;
     String name;
     double batteryLevel;
     int keepAlive;
     bool isDisabled;
     bool isActive;
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
     final String address;
     final DateTime date;
   }
   ```

## Example

To run the example put your server address and user token in `conf.dart`
