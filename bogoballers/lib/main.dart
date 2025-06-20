import 'package:bogoballers/administrator/administrator_app.dart';
import 'package:bogoballers/client/client_app.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/helpers/supabase_helpers.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/models/access_token.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:bogoballers/core/providers/player_provider.dart';
import 'package:bogoballers/core/providers/team_creator_provider.dart';
import 'package:bogoballers/core/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

/// 15/06/2025
Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  try {
    await dotenv.load(fileName: ".env");

    await Future.wait([
      AppBox.init(),
      Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      ),
    ]);

    checkSupabaseStatus();

    AccessToken? accessToken = AppBox.accessTokenBox.get('access_token');
    String? user_id;
    AccountTypeEnum? accountType;
    if (accessToken != null) {
      user_id = accessToken.user_id;
      accountType = AccountTypeEnum.fromValue(accessToken.getAccountType);
    }

    if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await NotificationService.instance.initialize(); // returns fcm token

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TeamCreatorProvider()),
            ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ],
          child: ClientMaterialScreen(
            user_id: user_id,
            accountType: accountType,
          ),
        ),
      );
    } else if (Platform.isWindows || Platform.isMacOS) {
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => LeagueAdministratorProvider(),
            ),
          ],
          child: AdministratorMaterialScreen(),
        ),
      );
    }
  } catch (e) {
    debugPrint("Error: $e");
  } finally {
    FlutterNativeSplash.remove();
  }
}
