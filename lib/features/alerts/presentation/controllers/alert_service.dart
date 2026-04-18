import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/providers/app_provider_class.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../core/utils/alert_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/permissions.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../../settings/domain/repository/settings_repository.dart';
import '../../domain/entities/expiry_reminder.dart';
import '../../domain/repositories/alert_repository.dart';
import 'alert_controller.dart';
import 'alert_scheduler.dart';
import 'notification_service.dart';

/// handle tap on notification
Future<void> onDidReceiveNotificationResponse(
  NotificationResponse response,
) async {
  if (response.payload == null || response.payload!.isEmpty) return;
  final storeProductId = response.payload!;

  final container = await AppProviders.container;

  final cache = container.read(localCacheServiceProvider);
  await cache.setString(
    key: AppConstants.pendingNotificationPayloadKey,
    value: storeProductId,
  );
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

    final alertsTypes = [
      ExpiryRemainder(daysBeforeExpiry: 30, importance: Priority.high),
      ExpiryRemainder(daysBeforeExpiry: 15, importance: Priority.high),
      ExpiryRemainder(daysBeforeExpiry: 7, importance: Priority.max),
      ExpiryRemainder(daysBeforeExpiry: 0, importance: Priority.max),
    ];

    for (final type in alertsTypes) {
      final days = type.daysBeforeExpiry;
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
        remainder: type,
      );
    }
  }

  Future<void> showNotification({
    required StoreProduct product,
    required ExpiryRemainder remainder,
  }) async {
    final payload = product.globalProduct.id;

    final remainingDays =
        DateTimeUtils.daysUntilExpiry(product.expiryDate) ?? 0;
    final String timeMsg =
        remainingDays <= 0 ? 'منتهي الصلاحية' : 'باقي $remainingDays يوم';

    await _notifications.show(
      id: AlertUtils.notificationId(product, remainder.daysBeforeExpiry),
      title: 'تنبيه صلاحية: ${product.globalProduct.name}',
      body: '${product.globalProduct.name} ($timeMsg)',
      payload: payload,
    );

    await alertController.addAlert(
      product: product,
      expiryRemainder: remainder,
    );
  }

  Future<void> _scheduleAlert({
    required StoreProduct product,
    required ExpiryRemainder remainder,
  }) async {
    if (product.expiryDate == null) return;
    final alertDate = product.expiryDate!
        .subtract(Duration(days: remainder.daysBeforeExpiry));

    if (alertDate.isBefore(DateTime.now())) {
      // إذا كان التاريخ في الماضي، أرسل التنبيه فورًا
      await showNotification(
        product: product,
        remainder: remainder,
      );
      return;
    }
    final payload = product.globalProduct.id?.toString();

    final String timeMsg = remainder.daysBeforeExpiry == 0
        ? 'منتهي الصلاحية'
        : 'باقي ${remainder.daysBeforeExpiry} يوم';

    await _notifications.schedule(
      id: AlertUtils.notificationId(product, remainder.daysBeforeExpiry),
      title: 'تنبيه صلاحية',
      body: '${product.globalProduct.name} ($timeMsg)',
      date: alertDate,
      payload: payload,
    );

    final delay = alertDate.difference(DateTime.now());
    await scheduleWorkManagerAlert(product, remainder.daysBeforeExpiry, delay);
  }

  Future<void> cancelProductAlerts(StoreProduct product) async {
    final daysList = {30, 15, 7, 0};

    for (final daysBefore in daysList) {
      final notificationId = AlertUtils.notificationId(product, daysBefore);
      await _notifications.cancel(notificationId);
    }
  }
}
