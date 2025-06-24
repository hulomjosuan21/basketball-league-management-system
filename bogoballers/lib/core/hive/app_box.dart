import 'package:bogoballers/core/models/access_token.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppBox {
  static const String accessTokenBoxName = 'access_token_box';
  static const String settingsBoxName = 'settings_box';

  static late Box<AccessToken> accessTokenBox;
  static late Box settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AccessTokenAdapter());

    accessTokenBox = await Hive.openBox<AccessToken>(accessTokenBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
  }

  static Future<void> clearAccessToken() async {
    await accessTokenBox.delete('access_token');
  }

  static Future<void> clearAll() async {
    await accessTokenBox.clear();
  }

  static Future<void> clearAllInBox<T>(Box<T> box) async {
    await box.clear();
  }
}
