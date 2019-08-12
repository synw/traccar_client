import 'package:traccar_client/traccar_client.dart';
import 'package:pedantic/pedantic.dart';
import 'conf.dart';

void main() async {
  final trac = DevicesPositions(
      serverUrl: serverUrl, userToken: userToken, verbose: true);
  unawaited(trac.init());
  await trac.onReady;

  /// listen for updates
  final positions = await trac.positions();
  print("Listening for position updates");
  positions.listen((device) {
    print("POSITION UPDATE");
    print("${device.name}: ${device.position.geoPoint.latitude} / " +
        "${device.position.geoPoint.longitude}");
  });

  /// query for last positions for a device
  final devices = await trac.queries.positions(
      deviceId: "2", from: "2019-08-01T18:30:00Z", to: "2019-08-12T13:30:00Z");
  for (final device in devices) {
    print(device);
  }
}
