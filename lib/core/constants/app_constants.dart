import 'enums.dart';

/// ثوابت التطبيق العامة
class AppConstants {
  AppConstants._();
  // Database
  static const String databaseName = 'SmartStore1.1.db';
  static const int databaseVersion =1;

  // Currency
  static const  defaultCurrency = Currency.YER;
  static const  defaultExchangeRate = 400.0; // 1 SAR = 300 YER

  // Barcode Types
  static const List<String> supportedBarcodeTypes = ['EAN-13', 'UPC'];

  // Notification IDs
  static const int notificationIdExpired = 1000;
  static const int notificationId30Days = 1001;
  static const int notificationId7Days = 1002;
  static const int notificationId1Day = 1003;

  static const String fontFamily = 'cairo';
}
