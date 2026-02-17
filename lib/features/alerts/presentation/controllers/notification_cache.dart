import 'package:shared_preferences/shared_preferences.dart';

class NotificationCache {
  NotificationCache._();
  static const _key = 'pending_notification_payload';

  /// save product id
  static Future<void> save(String payload) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, payload);
  }

  static Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
