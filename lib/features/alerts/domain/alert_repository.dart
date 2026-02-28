import '../../../errors/result.dart';
import 'alert.dart';

/// واجهة مستودع التنبيهات
abstract class AlertRepository {
  /// الحصول على جميع التنبيهات
  Future<Result<List<Alert>>> getAllAlerts();

  /// الحصول على التنبيهات غير المقروءة
  Future<Result<List<Alert>>> getUnreadAlerts();

  Future<Result<List<Alert>>> getNewAlerts();

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
  Future<Result<void>> deleteAlert(String id);

  /// حذف جميع التنبيهات
  Future<Result<void>> deleteAllAlerts();
}
