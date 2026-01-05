import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  /// حساب الأيام المتبقية حتى تاريخ الانتهاء
  static int? daysUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return null;
    final today = DateTime.now();

    return expiryDate.difference(today).inDays;
  }

  /// المدة المتبقية بصيغة كلمات مقروءة (سنين / شهور / أيام)
  static String? timeUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return null;
    final now = DateTime.now();

    if (expiryDate.isBefore(now)) {
      return 'منتهي';
    }

    int years = expiryDate.year - now.year;
    int months = expiryDate.month - now.month;
    int days = expiryDate.day - now.day;

    if (days < 0) {
      months--;

      days += DateTime(expiryDate.year, expiryDate.month, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return months > 0 ? '$years سنة و $months شهر' : '$years سنة';
    }

    return months > 0 ? '$months شهر' : '$days يوم';
  }

  /// التحقق من انتهاء المنتج
  static bool? isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return null;
    return daysUntilExpiry(expiryDate)! < 0;
  }

  /// التحقق من قرب انتهاء المنتج
  static bool isNearExpiry(DateTime expiryDate, int daysThreshold) {
    final days = daysUntilExpiry(expiryDate);
    return days! >= 0 && days <= daysThreshold;
  }

  /// تنسيق التاريخ للعرض
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd', 'en').format(date);
  }
}
