
/// ثوابت التطبيق العامة
class AppConstants {
  AppConstants._();
  // Database
  static const String databaseName = 'SmartStore1.5.db';
  static const int databaseVersion = 1;

  // Currency

  // Notification IDs
  static const int notificationIdExpired = 1000;
  static const int notificationId30Days = 1001;
  static const int notificationId7Days = 1002;
  static const int notificationId1Day = 1003;

  static const String fontFamily = 'cairo';

  static const String lastUserIdKey = 'last_user_id';

  static const String profilesTable = 'profiles';

  static const String profileUserIdKey = 'profile_user';
}
