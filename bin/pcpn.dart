

import 'package:pcpn/server.dart';

Future<void> main() async {
  await server();
  await mySqlConenction();
}
