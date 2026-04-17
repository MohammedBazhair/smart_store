import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../app_initializer.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../core/utils/alert_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../main.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../../settings/domain/repository/settings_repository.dart';
import '../../data/models/alert_model.dart';
import '../../domain/entities/expiry_reminder.dart';
import '../../domain/repositories/alert_repository.dart';
import 'alert_controller.dart';
import 'alert_scheduler.dart';
import 'notification_service.dart';

/// handle tap on notification
void onDidReceiveNotificationResponse(NotificationResponse response) async {
  Logger.debugLog(
    message: 'Received notification response: ${response.id}',
  );
  if (response.payload == null || response.payload!.isEmpty) return;
  final storeProductId = response.payload!;

  // Wait a bit to ensure AppProviders.container is initialized
  // if this is called at the very first frame of the app.
  int retries = 0;
  while (retries < 10) {
    try {
      final container = AppProviders.container;
      final isReady = navigatorKey.currentState != null;

      if (!isReady) {
        final cache = container.read(localCacheServiceProvider);
        await cache.setString(
          key: AppConstants.pendingNotificationPayloadKey,
          value: storeProductId,
        );
        return;
      }

      container.read(currentProductIdProvider.notifier).state = storeProductId;
      final cache = container.read(localCacheServiceProvider);
      await cache.setString(
        key: AppConstants.pendingNotificationPayloadKey,
        value: storeProductId,
      );

      const detatailsScreen = ProductDetailsScreen();
      await navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => detatailsScreen));
      break;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 200));
      retries++;
    }
  }
}

class AlertService {
  AlertService(
    this.settingsRepo,
    this.alertRepository,
    this._notifications,
    this.alertController,
  );

  final SettingsRepository settingsRepo;
  final AlertRepository alertRepository;
  final AlertController alertController;
  final NotificationService _notifications;

  Future<void> initialize([bool requestPermissions = true]) async {
    if (requestPermissions) await PermissionsService.requestNotification();
    await _notifications.initialize();
  }

  Future<void> scheduleProductAlerts(StoreProduct product) async {
    final result = await settingsRepo.getSettings();
    if (!result.enableNotifications) return;

    if (product.expiryDate == null) return;

    final alerts = [
      ExpiryReminder(daysBefore: 30, importance: Priority.high),
      ExpiryReminder(daysBefore: 15, importance: Priority.high),
      ExpiryReminder(daysBefore: 7, importance: Priority.max),
      ExpiryReminder(daysBefore: 0, importance: Priority.max),
    ];

    for (final alert in alerts) {
      final days = alert.daysBefore;
      final importance = alert.importance;
      final isNearExpired =
          DateTimeUtils.isNearExpiry(product.expiryDate!, days);

      final isAlertDuplicated = await alertRepository.isAlertDuplicated(
        productId: product.globalProduct.id!,
        expiryDate: product.expiryDate!,
        daysBeforeExpiry: days,
      );

      if (isAlertDuplicated || !isNearExpired) continue;

      await _scheduleAlert(
        product: product,
        daysBefore: days,
        importance: importance,
      );
    }
  }

  Future<void> showNotification({
    required StoreProduct product,
    required int daysBefore,
  }) async {
    final payload = product.globalProduct.id;

    final remainingDays =
        DateTimeUtils.daysUntilExpiry(product.expiryDate) ?? 0;
    final String timeMsg =
        remainingDays <= 0 ? 'منتهي الصلاحية' : 'باقي $remainingDays يوم';

    await _notifications.show(
      id: AlertUtils.notificationId(product, daysBefore),
      title: 'تنبيه صلاحية: ${product.globalProduct.name}',
      body: '${product.globalProduct.name} ($timeMsg)',
      payload: payload,
    );

    await alertController.addAlert(
      product: product,
      daysBeforeExpiry: daysBefore,
      importance: AlertModel.getPriorityFrom(daysBefore),
    );
  }

  Future<void> _scheduleAlert({
    required StoreProduct product,
    required int daysBefore,
    required Priority importance,
  }) async {
    if (product.expiryDate == null) return;
    final alertDate = product.expiryDate!.subtract(Duration(days: daysBefore));

    if (alertDate.isBefore(DateTime.now())) {
      // إذا كان التاريخ في الماضي، أرسل التنبيه فورًا
      await showNotification(
        product: product,
        daysBefore: daysBefore,
      );
      return;
    }
    final payload = product.globalProduct.id?.toString();

    final String timeMsg =
        daysBefore == 0 ? 'منتهي الصلاحية' : 'باقي $daysBefore يوم';

    await _notifications.schedule(
      id: AlertUtils.notificationId(product, daysBefore),
      title: 'تنبيه صلاحية',
      body: '${product.globalProduct.name} ($timeMsg)',
      date: alertDate,
      payload: payload,
    );

    final delay = alertDate.difference(DateTime.now());
    await scheduleWorkManagerAlert(product, daysBefore, delay);
  }

  Future<void> cancelProductAlerts(StoreProduct product) async {
    final daysList = {30, 15, 7, 0};

    for (final daysBefore in daysList) {
      final notificationId = AlertUtils.notificationId(product, daysBefore);
      await _notifications.cancel(notificationId);
    }
  }
}
