import 'package:shared_preferences/shared_preferences.dart';

class NotificationCache {
  NotificationCache._();
  static const _key = 'pending_notification_payload';

  /// save product id
  static Future<void> save(int payload) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_key, payload);
  }

  static Future<int?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
