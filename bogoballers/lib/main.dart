import 'package:bogoballers/administrator/administrator_app.dart';
import 'package:bogoballers/client/client_app.dart';
import 'package:bogoballers/core/state/app_state.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/helpers/supabase_helpers.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/models/access_token.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/notification_services.dart';
import 'package:bogoballers/service_locator.dart';
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

  setupLocator();

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
      await NotificationService.instance.initialize();
    }

    final List<ChangeNotifierProvider> providers = [];

    if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
      providers.addAll([
        ChangeNotifierProvider<EntityState<PlayerModel>>.value(
          value: getIt<EntityState<PlayerModel>>(),
        ),
        ChangeNotifierProvider<EntityState<UserModel>>.value(
          value: getIt<EntityState<UserModel>>(),
        ),
      ]);
    } else if (Platform.isWindows || Platform.isMacOS) {
      providers.addAll([
        ChangeNotifierProvider<EntityState<LeagueAdministratorModel>>.value(
          value: getIt<EntityState<LeagueAdministratorModel>>(),
        ),
        ChangeNotifierProvider<AppState>.value(value: getIt<AppState>()),
      ]);
    }

    runApp(
      MultiProvider(
        providers: providers,
        child: (kIsWeb || Platform.isIOS || Platform.isAndroid)
            ? ClientMaterialScreen(user_id: user_id, accountType: accountType)
            : AdministratorMaterialScreen(
                user_id: user_id,
                accountType: accountType,
              ),
      ),
    );
  } catch (e) {
    debugPrint("Error: $e");
  } finally {
    FlutterNativeSplash.remove();
  }
}
