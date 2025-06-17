import 'package:bogoballers/administrator/administrator_app.dart';
import 'package:bogoballers/client/client_app.dart';
import 'package:bogoballers/core/helpers/supabase_helpers.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:bogoballers/core/providers/player_provider.dart';
import 'package:bogoballers/core/providers/team_creator_provider.dart';
import 'package:bogoballers/core/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// 15/06/2025
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await AppBox.init();
  await NotificationService.instance.initialize();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  checkSupabaseStatus();
  if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => TeamCreatorProvider()),
        ],
        child: ClientMaterialScreen(),
      ),
    );
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
