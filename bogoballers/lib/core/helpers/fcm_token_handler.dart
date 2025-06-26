import 'package:bogoballers/core/helpers/supabase_helpers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bogoballers/core/hive/app_box.dart';

class FCMTokenHandler {
  static String _lastSentTokenKey(String userId) =>
      'last_sent_fcm_token_$userId';

  static Future<void> syncToken(String userId) async {
    final fcm = FirebaseMessaging.instance;
    final currentToken = await fcm.getToken();

    if (currentToken == null) return;

    final key = _lastSentTokenKey(userId);
    final savedToken = AppBox.settingsBox.get(key);

    if (savedToken != currentToken) {
      final response = await updateUserFcmToken(userId, currentToken);
      print('[FCM Sync] Token updated: ${response.message}');
      AppBox.settingsBox.put(key, currentToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final response = await updateUserFcmToken(userId, newToken);
      print('[FCM Sync] Token refreshed: ${response.message}');
      AppBox.settingsBox.put(key, newToken);
    });
  }

  static Future<void> clearToken(String userId) async {
    final key = _lastSentTokenKey(userId);
    await AppBox.settingsBox.delete(key);
    print('[FCM Sync] Cleared token for user: $userId');
  }
}
