# Traccar client

Dart client for the Traccar geolocation server. Get real time devices positions updates from a
[Traccar](http://traccar.org/) server.

## Usage

### Initialize

   ```dart
   import 'package:pedantic/pedantic.dart';
   import 'package:traccar_client/traccar_client.dart';
   import 'conf.dart';

   /// [serverUrl] and [userToken] are taken from conf
   final trac = Traccar(serverUrl: serverUrl, userToken: userToken);
   unawaited(trac.init());
   await trac.onReady;
   ```

### Listen for positions updates

   ```dart
   final positions = await trac.positions();
   print("Listening for position updates");
   positions.listen((device) {
      print("POSITION UPDATE: $device");
      print("${device.id}: ${device.position.geoPoint.latitude} / " +
         "${device.position.geoPoint.longitude}");
   });
   ```

## Run queries

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
