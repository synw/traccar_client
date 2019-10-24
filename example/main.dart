import 'package:traccar_client/traccar_client.dart';
import 'package:pedantic/pedantic.dart';
import 'package:device/device.dart';
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
    print("${device.name}: ${device.position.latitude} / " +
        "${device.position.longitude}");
  });

  /// devices
  await trac.query.devices().then((List<Device> devices) {
    print("DEVICES LIST:");
    print("$devices");
  });
}
