import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../errors/result.dart';
import '../../../products/domain/entities/seller_product.dart';
import '../../domain/alert.dart';
import 'alert_provider.dart';

class AlertController extends Notifier<void> {
  @override
  void build() {}

  /// إضافة تنبيه
  Future<Result<int>> addAlert({
    required SellerProduct product,
    required int daysBeforeExpiry,
    required Priority importance,
  }) async {
    final repository = ref.read(alertRepositoryProvider);
    final alert = Alert(
      productId: product.id!,
      daysBeforeExpiry: daysBeforeExpiry,
      importance: importance,
      isRead: false,
      createdAt: DateTime.now(),
      expiryDate: product.expiryDate,
      productName: product.name,
    );

    final result = await repository.addAlert(alert);

    if (result is SuccessState<int>) {
      _invalidate();
      return result;
    }

    return result as ErrorState<int>;
  }

  /// تحديد التنبيه كمقروء
  Future<Result<void>> markAsRead(int id) async {
    final repository = ref.read(alertRepositoryProvider);
    final result = await repository.markAlertAsRead(id);

    if (result is SuccessState<void>) _invalidate();

    return result;
  }

  /// حذف تنبيه
  Future<Result<void>> deleteAlert(String id) async {
    final repository = ref.read(alertRepositoryProvider);
    final result = await repository.deleteAlert(id);

    if (result is SuccessState<void>) _invalidate();

    return result;
  }

  Future<bool> isAlertDuplicated({
    required int productId,
    required DateTime expiryDate,
    required int daysBeforeExpiry,
  }) async {
    final repository = ref.read(alertRepositoryProvider);
    final isDuplicated = await repository.isAlertDuplicated(
      productId: productId,
      expiryDate: expiryDate,
      daysBeforeExpiry: daysBeforeExpiry,
    );
    return isDuplicated;
  }

  /// تحديث قائمة التنبيهات
  void _invalidate() {
    ref.invalidate(alertsProvider);
    ref.invalidate(newAlertsProvider);
  }
}

/// Provider للـ AlertController
final alertControllerProvider = NotifierProvider<AlertController, void>(() {
  return AlertController();
});
