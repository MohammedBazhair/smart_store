import '../../../../errors/result.dart';
import '../entities/alert.dart';

/// واجهة مستودع التنبيهات
abstract class AlertRepository {
  Future<Map<int, Alert>> getAllAlerts();

  Future<Map<int, Alert>> getUnreadAlerts();

  Future<Result<int>> addAlert(Alert alert);

  Future<Result<void>> markAlertAsRead(int id);

  Future<bool> isAlertDuplicated({
    required String productId,
    required DateTime expiryDate,
    required int daysBeforeExpiry,
  });

   Future<void> deleteAlert(int id);

  Future<void> deleteReadAlerts();
}
