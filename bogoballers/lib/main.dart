import 'package:bogoballers/administrator/administrator_app.dart';
import 'package:bogoballers/client/client_app.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppBox.init();
  if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
    runApp(ClientMaterialScreen());
  } else if (Platform.isWindows || Platform.isMacOS) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LeagueAdministratorProvider()),
        ],
        child: AdministratorMaterialScreen(),
      ),
    );
  }
}
