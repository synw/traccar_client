# Example

To run the example put your server address and user token in `conf.dart`

```dart
import 'package:traccar_client/traccar_client.dart';
import 'package:pedantic/pedantic.dart';
import 'conf.dart';

void main() async {
  final trac =
      Traccar(serverUrl: serverUrl, userToken: userToken, verbose: true);
  unawaited(trac.init());
  await trac.onReady;

  /// listen for updates
  final positions = await trac.positions();
  print("Listening for position updates");
  positions.listen((device) {
    print("POSITION UPDATE: $device");
    print("${device.name}: ${device.position.geoPoint.latitude} / " +
        "${device.position.geoPoint.longitude}");
  });

  /// devices
  await trac.query.devices().then((List<Device> devices) {
    print("DEVICES LIST:");
    print("$devices");
  });
}
```
