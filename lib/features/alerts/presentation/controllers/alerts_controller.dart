import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../core/shared/providers/ui_providers.dart';
import '../../../../errors/result.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../domain/entities/alert.dart';
import '../../domain/entities/expiry_reminder.dart';
import '../../domain/repositories/alert_repository.dart';
import 'alerts_state.dart';

class AlertsController extends Notifier<AlertsState> {
  @override
  AlertsState build() {
    Future.microtask(loadAlerts);
    return AlertsState.empty();
  }

  AlertRepository get _repo => ref.read(alertRepositoryProvider);
  AppUiEventController get _uiController =>
      ref.read(appUiEventProvider.notifier);

  Future<void> loadAlerts() async {
    final [allAlerts, unreadAlerts] = await Future.wait([
      _repo.getAllAlerts(),
      _repo.getUnreadAlerts(),
    ]);

    state = AlertsState(
      allAlerts: allAlerts,
      unreadAlerts: unreadAlerts,
    );
  }

  Future<void> addAlert({
    required StoreProduct product,
    required ExpiryRemainder expiryRemainder,
  }) async {
    if (product.expiryDate == null) return;
    final alert = Alert(
      productId: product.globalProduct.id!,
      isRead: false,
      createdAt: DateTime.now().toUtc(),
      expiryDate: product.expiryDate!,
      productName: product.globalProduct.name,
      expiryRemainder: expiryRemainder,
    );

    final result = await _repo.addAlert(alert);

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
    final result = await _repo.markAlertAsRead(id);

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

  Future<void> deleteAlert(int id) async {
    try {
      await _repo.deleteAlert(id);

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

      _uiController.showSuccess('تم حذف التنبيه بنجاح');
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);

      _uiController.showError('حصلت مشكلة أثناء حذف التنبيه');
    }
  }

  Future<void> clearOldAlerts() async {
    try {
      await _repo.deleteReadAlerts();

      final copiedAlerts = {...state.allAlerts};

      copiedAlerts.removeWhere((key, value) => value.isRead);

      state = state.copyWith(allAlerts: copiedAlerts);
      _uiController.showSuccess('تم حذف التنبيهات المقروءة بنجاح');
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);

      _uiController.showError(
        'حصلت مشكلة غير متوقعة أثناء محاولة حذف التنبيهات المقروءة',
      );
    }
  }
}
