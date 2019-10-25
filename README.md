# Traccar client

[![pub package](https://img.shields.io/pub/v/traccar_client.svg)](https://pub.dartlang.org/packages/traccar_client)

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

The token is a user token that you can generate from the Traccar web interface

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

### Get a list of devices

   ```dart
   trac.query.devices().then((List<Device> devices) {
      print("$devices");
   });
   ```

### Get positions history for a device

```dart
   final List<Device> pos = await trac.query.positions(
      deviceId: "1", since: Duration(hours: 3));
   ```

## Data structure

[Device](https://github.com/synw/device): representation of a device

[GeoPoint](https://github.com/synw/geopoint): geographical datapoints: [data structure](https://github.com/synw/geopoint#geopoint-1)

## Example

To run the example put your server address and user token in `conf.dart`
