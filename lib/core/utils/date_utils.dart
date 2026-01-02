import 'package:intl/intl.dart';

/// أدوات للتعامل مع التواريخ
class DateUtils {
  /// حساب الأيام المتبقية حتى تاريخ الانتهاء
  static int daysUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  /// التحقق من انتهاء المنتج
  static bool isExpired(DateTime expiryDate) {
    return daysUntilExpiry(expiryDate) < 0;
  }

  /// التحقق من قرب انتهاء المنتج
  static bool isNearExpiry(DateTime expiryDate, int daysThreshold) {
    final days = daysUntilExpiry(expiryDate);
    return days >= 0 && days <= daysThreshold;
  }

  /// تنسيق التاريخ للعرض
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM', 'en').format(date);
  }

  /// تنسيق التاريخ والوقت
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm', 'ar').format(date);
  }

  /// تحويل String إلى DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
