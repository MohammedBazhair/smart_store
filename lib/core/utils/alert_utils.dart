import 'package:timezone/timezone.dart' as tz;

import '../../features/products/domain/entities/store_product.dart';

class AlertUtils {
  AlertUtils._();

  static int notificationId(StoreProduct product, int daysBefore) {
    final productId = product.id!;
    final notificationId = '${productId}_$daysBefore';
    const t = 0x7fffffff; // رقم موجب فقط
    return notificationId.hashCode & t;
  }

  /// Converts the calculated alert date to a timezone-aware datetime
  /// to ensure accurate notification scheduling across different locales
  static tz.TZDateTime getAlertScheduleDate(
    StoreProduct product,
    int daysBefore,
  ) {
    final alertDate = product.expiryDate!.subtract(Duration(days: daysBefore));
    return tz.TZDateTime.from(alertDate, tz.local);
  }
}
