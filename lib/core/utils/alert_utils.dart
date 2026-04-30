import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/products/domain/entities/store_product.dart';

class AlertUtils {
  AlertUtils._();

  static String _buildNotificationKey(StoreProduct product, int daysBefore) {
    final productId = product.id ?? '';
    return '${productId}_$daysBefore';
  }

  static List<int> _generateMd5Bytes(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.bytes;
  }

  static int _bytesToPositiveInt(List<int> bytes) {
    const mask = 0x7fffffff;

    final value = bytes.take(4).fold<int>(0, (result, byte) {
      /* Shift the current result 8 bits to the left 
         (make room for next byte)
         then add the new byte using bitwise OR to build a 32-bit integer 
      */
      return (result << 8) | byte;
    });

    return value & mask;
  }

  static int notificationId(StoreProduct product, int daysBefore) {
    final uniqueKey = _buildNotificationKey(product, daysBefore);

    final hashBytes = _generateMd5Bytes(uniqueKey);
    final id = _bytesToPositiveInt(hashBytes);

    return id;
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
