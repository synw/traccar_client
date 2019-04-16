# Traccar client

Traccar client for Dart. Get real time devices positions updates from a 
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
         print("POSITION UPDATE");
         print("${device.name}: ${device.position.point.latitude} / " +
            "${device.position.point.longitude}");
      });
   }
   ```

## Data structure

The position stream outputs `Device` objects with updated positions:

   ```dart
   class Device {
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
   }
   ```
