import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../errors/result.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../domain/alert.dart';

class AlertController extends Notifier<AlertsState> {
  @override
  AlertsState build() {
    return AlertsState.empty();
  }

  Future<void> loadAlerts() async {
    final repository = ref.read(alertRepositoryProvider);
    final allAlerts = await repository.getAllAlerts();
    final newAlerts = await repository.getNewAlerts();
    final unreadAlerts = await repository.getUnreadAlerts();

    state = AlertsState(
      allAlerts: allAlerts,
      newAlerts: newAlerts,
      unreadAlerts: unreadAlerts,
    );
  }

  Future<void> addAlert({
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
      createdAt: DateTime.now().toUtc(),
      expiryDate: product.expiryDate,
      productName: product.globalProduct.name,
    );

    final result = await repository.addAlert(alert);

    if (result is SuccessState<int>) {
      final id = result.data;
      final alertWithId = alert.copyWith(id: id);
      final copiedAlerts = {...state.allAlerts, id: alertWithId};
      final copiedNewAlerts = {...state.newAlerts, id: alertWithId};
      state =
          state.copyWith(allAlerts: copiedAlerts, newAlerts: copiedNewAlerts);
      return;
    }
  }

  Future<void> markAsRead(int id) async {
    final repository = ref.read(alertRepositoryProvider);
    final result = await repository.markAlertAsRead(id);

    if (result is! SuccessState<void>) return;

    final alert = state.allAlerts[id];
    if (alert == null) return;

    final copiedNewAlerts = {...state.newAlerts}..remove(id);
    final copiedUnreadAlerts = {...state.unreadAlerts, id: alert};

    state = state.copyWith(
      newAlerts: copiedNewAlerts,
      unreadAlerts: copiedUnreadAlerts,
    );
  }

  Future<Result<void>> deleteAlert(int id) async {
    final repository = ref.read(alertRepositoryProvider);
    final result = await repository.deleteAlert(id);

    if (result is! SuccessState<void>) return result;

    final isAlertInAll = state.allAlerts.containsKey(id);
    final isAlertNew = state.newAlerts.containsKey(id);
    final isAlertUnread = state.unreadAlerts.containsKey(id);

    final copiedAllAlerts =
        isAlertInAll ? {...state.allAlerts} : state.allAlerts;
    final copiedNewAlerts = isAlertNew ? {...state.newAlerts} : state.newAlerts;
    final copiedUnreadAlerts =
        isAlertUnread ? {...state.unreadAlerts} : state.unreadAlerts;

    copiedAllAlerts.remove(id);
    copiedNewAlerts.remove(id);
    copiedUnreadAlerts.remove(id);

    state = state.copyWith(
      allAlerts: copiedAllAlerts,
      newAlerts: copiedNewAlerts,
      unreadAlerts: copiedUnreadAlerts,
    );
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
}

class AlertsState {
  AlertsState({
    required this.allAlerts,
    required this.newAlerts,
    required this.unreadAlerts,
  });

  factory AlertsState.empty() => AlertsState(
        allAlerts: {},
        newAlerts: {},
        unreadAlerts: {},
      );
  final Map<int, Alert> allAlerts;
  final Map<int, Alert> newAlerts;
  final Map<int, Alert> unreadAlerts;

  AlertsState copyWith({
    Map<int, Alert>? allAlerts,
    Map<int, Alert>? newAlerts,
    Map<int, Alert>? unreadAlerts,
  }) {
    return AlertsState(
      allAlerts: allAlerts ?? this.allAlerts,
      newAlerts: newAlerts ?? this.newAlerts,
      unreadAlerts: unreadAlerts ?? this.unreadAlerts,
    );
  }
}
