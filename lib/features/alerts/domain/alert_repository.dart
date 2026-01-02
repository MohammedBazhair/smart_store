import '../../../core/utils/result.dart';
import 'alert.dart';

/// واجهة مستودع التنبيهات
abstract class AlertRepository {
  /// الحصول على جميع التنبيهات
  Future<Result<List<Alert>>> getAllAlerts();

  /// الحصول على التنبيهات غير المقروءة
  Future<Result<List<Alert>>> getUnreadAlerts();

  /// إضافة تنبيه
  Future<Result<int>> addAlert(Alert alert);

  /// تحديث حالة التنبيه (مقروء/غير مقروء)
  Future<Result<void>> markAlertAsRead(int id);

  /// حذف تنبيه
  Future<Result<void>> deleteAlert(String id);

  /// حذف جميع التنبيهات
  Future<Result<void>> deleteAllAlerts();
}
