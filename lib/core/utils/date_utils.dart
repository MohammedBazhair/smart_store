import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  /// حساب الأيام المتبقية حتى تاريخ الانتهاء
  static int? daysUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.difference(today).inDays;
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

      final daysInPreviousMonth =
          DateTime(expiryDate.year, expiryDate.month, 0).day;

      days += daysInPreviousMonth;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final parts = <String>[];

    if (years > 0) parts.add('$years سنة');

    if (months > 0) parts.add('$months شهر');

    if (years == 0 && days > 0) parts.add('$days يوم');

    return parts.join(' و ');
  }

  /// التحقق من انتهاء المنتج
  static bool? isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return null;
    return daysUntilExpiry(expiryDate)! < 0;
  }

  /// التحقق من قرب انتهاء المنتج
  static bool isNearExpiry(DateTime expiryDate, int daysThreshold) {
    final days = daysUntilExpiry(expiryDate);

    if (days == null) return false;
    return days >= 0 && days <= daysThreshold;
  }

  /// تنسيق التاريخ للعرض
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd', 'en').format(date);
  }
}
