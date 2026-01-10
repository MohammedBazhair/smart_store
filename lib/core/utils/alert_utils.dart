import 'package:timezone/timezone.dart' as tz;

import '../../features/products/domain/product.dart';

class AlertUtils {
  AlertUtils._();

  // Stable notification ID (productId * 100 + daysBefore)
  static int notificationId(Product product, int daysBefore) {
    // daysBefore must be < 100 to avoid collisions.
    const daysMultiplier = 100;
    final productId = product.id!;
    final notificationId = productId * daysMultiplier + daysBefore;
    return notificationId;
  }

/// Converts the calculated alert date to a timezone-aware datetime
/// to ensure accurate notification scheduling across different locales
  static tz.TZDateTime getAlertScheduleDate(Product product, int daysBefore) {
    final alertDate = product.expiryDate!.subtract(Duration(days: daysBefore));
    return tz.TZDateTime.from(alertDate, tz.local);
  }
}
