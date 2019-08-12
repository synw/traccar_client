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
  final devices = await trac.query.positions(
    deviceId: "1", since: Duration(days: 7),
    //timeZoneOffset: "+2"
  );
  for (final device in devices) {
    print(device);
  }
}
