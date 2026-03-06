import '../../../errors/result.dart';
import 'alert.dart';

/// واجهة مستودع التنبيهات
abstract class AlertRepository {
  /// الحصول على جميع التنبيهات
  Future<Map<int, Alert>> getAllAlerts();

  /// الحصول على التنبيهات غير المقروءة
  Future<Map<int, Alert>> getUnreadAlerts();

  Future<Map<int, Alert>> getNewAlerts();

  /// إضافة تنبيه
  Future<Result<int>> addAlert(Alert alert);

  /// تحديث حالة التنبيه (مقروء/غير مقروء)
  Future<Result<void>> markAlertAsRead(int id);

  /// تحقق إذا التبيه موجود مسبقًا
  Future<bool> isAlertDuplicated({
    required String productId,
    required DateTime expiryDate,
    required int daysBeforeExpiry,
  });

  /// حذف تنبيه
  Future<Result<void>> deleteAlert(int id);

  /// حذف جميع التنبيهات
  Future<Result<void>> deleteAllAlerts();
}
