import 'package:bogoballers/core/helpers/supabase_helpers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bogoballers/core/hive/app_box.dart';

class FCMTokenHandler {
  static const String _lastSentTokenKey = 'last_sent_fcm_token';

  static Future<void> syncToken(String userId) async {
    final fcm = FirebaseMessaging.instance;
    final currentToken = await fcm.getToken();

    if (currentToken == null) return;

    final savedToken = AppBox.settingsBox.get(_lastSentTokenKey);

    if (savedToken != currentToken) {
      final response = await updateUserFcmToken(userId, currentToken);
      print(response.message);
      AppBox.settingsBox.put(_lastSentTokenKey, currentToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final response = await updateUserFcmToken(userId, newToken);
      print(response.message);
      AppBox.settingsBox.put(_lastSentTokenKey, newToken);
    });
  }
}
