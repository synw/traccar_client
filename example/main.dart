import 'package:traccar_client/traccar_client.dart';
import 'conf.dart';

main() async {
  var updater = DevicesPositions(serverUrl: serverUrl, userToken: userToken);
  var positions = await updater.positions();
  positions.listen((device) {
    print("POSITION UPDATE");
    print("${device.name}: ${device.position.point.latitude} / " +
        "${device.position.point.longitude}");
  });
}
