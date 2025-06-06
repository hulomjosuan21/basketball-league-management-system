import 'package:bogoballers/core/models/access_token.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppBox {
  static const String accessTokenBoxName = 'access_token_box';

  static late Box<AccessToken> accessTokenBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AccessTokenAdapter());

    accessTokenBox = await Hive.openBox<AccessToken>(accessTokenBoxName);
  }

  static Future<void> clearAll() async {
    await accessTokenBox.clear();
  }
}
