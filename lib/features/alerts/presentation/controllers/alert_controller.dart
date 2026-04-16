import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../errors/result.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';

class AlertController extends Notifier<AlertsState> {
  @override
  AlertsState build() {
    Future.microtask(loadAlerts);
    return AlertsState.empty();
  }

  AlertRepository get repository => ref.read(alertRepositoryProvider);

  Future<void> loadAlerts() async {
    final allAlerts = await repository.getAllAlerts();
    final unreadAlerts = await repository.getUnreadAlerts();

    state = AlertsState(
      allAlerts: allAlerts,
      unreadAlerts: unreadAlerts,
    );
  }

  Future<void> addAlert({
    required StoreProduct product,
    required int daysBeforeExpiry,
    required Priority importance,
  }) async {
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

    if (result is! SuccessState<int>) return;

    final id = result.data;
    final alertWithId = alert.copyWith(id: id);

    final copiedAllAlerts = {...state.allAlerts, id: alertWithId};
    final copiedUnreadAlerts = {...state.unreadAlerts, id: alertWithId};

    state = state.copyWith(
      allAlerts: copiedAllAlerts,
      unreadAlerts: copiedUnreadAlerts,
    );
  }

  Future<void> markAsRead(int id) async {
    final result = await repository.markAlertAsRead(id);

    if (result is! SuccessState<void>) return;

    final alert = state.allAlerts[id];
    if (alert == null) return;

    final updatedAlert = alert.copyWith(isRead: true);

    final copiedAllAlerts = {...state.allAlerts, id: updatedAlert};
    final copiedUnreadAlerts = {...state.unreadAlerts}..remove(id);

    state = state.copyWith(
      allAlerts: copiedAllAlerts,
      unreadAlerts: copiedUnreadAlerts,
    );
  }

  Future<Result<void>> deleteAlert(int id) async {
    final result = await repository.deleteAlert(id);

    if (result is! SuccessState<void>) return result;

    final isUnreadAlert = state.unreadAlerts.containsKey(id);

    final copiedAllAlerts = {...state.allAlerts};
    final copiedUnreadAlerts =
        isUnreadAlert ? {...state.unreadAlerts} : state.unreadAlerts;

    copiedAllAlerts.remove(id);
    copiedUnreadAlerts.remove(id);

    state = state.copyWith(
      allAlerts: copiedAllAlerts,
      unreadAlerts: copiedUnreadAlerts,
    );
    return result;
  }
}

class AlertsState {
  AlertsState({
    required this.allAlerts,
    required this.unreadAlerts,
  });

  factory AlertsState.empty() => AlertsState(
        allAlerts: {},
        unreadAlerts: {},
      );
  final Map<int, Alert> allAlerts;
  final Map<int, Alert> unreadAlerts;

  AlertsState copyWith({
    Map<int, Alert>? allAlerts,
    Map<int, Alert>? unreadAlerts,
  }) {
    return AlertsState(
      allAlerts: allAlerts ?? this.allAlerts,
      unreadAlerts: unreadAlerts ?? this.unreadAlerts,
    );
  }
}
