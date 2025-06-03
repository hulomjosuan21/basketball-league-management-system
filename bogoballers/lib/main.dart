import 'package:bogoballers/administrator/administrator_app.dart';
import 'package:bogoballers/client/client_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
    runApp(ClientMaterialScreen());
  } else if (Platform.isWindows || Platform.isMacOS) {
    runApp(AdministratorMaterialScreen());
  }
}
