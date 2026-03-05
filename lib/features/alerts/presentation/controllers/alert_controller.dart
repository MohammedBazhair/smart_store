import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../errors/result.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../domain/alert.dart';
import 'alert_provider.dart';

class AlertController extends Notifier<AlertsState> {
  @override
  AlertsState build() {
    return AlertsState.empty();
  }

  Future<void> loadAlerts() async {
    final repository = ref.read(alertRepositoryProvider);
    final allAlerts = await repository.getAllAlerts();
  final newAlerts=   await repository.getNewAlerts();
   final unreadAlerts = await repository.getUnreadAlerts();

    state = AlertsState(
      allAlerts: allAlerts,
      newAlerts: newAlerts,
      unreadAlerts: unreadAlerts,
    );
  }

  /// إضافة تنبيه
  Future<Result<int>> addAlert({
    required StoreProduct product,
    required int daysBeforeExpiry,
    required Priority importance,
  }) async {
    final repository = ref.read(alertRepositoryProvider);
    final alert = Alert(
      productId: product.globalProduct.id!,
      daysBeforeExpiry: daysBeforeExpiry,
      importance: importance,
      isRead: false,
      createdAt: DateTime.now(),
      expiryDate: product.expiryDate,
      productName: product.globalProduct.name,
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
    required String productId,
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

class AlertsState {
  AlertsState({
    required this.allAlerts,
    required this.newAlerts,
    required this.unreadAlerts,
  });

  factory AlertsState.empty() => AlertsState(
        allAlerts: [],
        newAlerts: [],
        unreadAlerts: [],
      );
  final List<Alert> allAlerts;
  final List<Alert> newAlerts;
  final List<Alert> unreadAlerts;

  AlertsState copyWith({
    List<Alert>? allAlerts,
    List<Alert>? newAlerts,
    List<Alert>? unreadAlerts,
  }) {
    return AlertsState(
      allAlerts: allAlerts ?? this.allAlerts,
      newAlerts: newAlerts ?? this.newAlerts,
      unreadAlerts: unreadAlerts ?? this.unreadAlerts,
    );
  }
}
