import 'package:intl/intl.dart';

/// أدوات للتعامل مع التواريخ
class DateUtils {
  /// حساب الأيام المتبقية حتى تاريخ الانتهاء
  static int? daysUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  /// ترجع المدة المتبقية بصيغة مناسبة (أيام / أشهر / سنين)
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
      months -= 1;
      final previousMonth = DateTime(expiryDate.year, expiryDate.month, 0).day;
      days += previousMonth;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years > 0) {
      return months > 0 ? '$years سنة و $months شهر' : '$years سنة';
    }

    return months > 0 ? '$months شهور' : '$days أيام';
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
