import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/utils/alert_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../main.dart';
import '../../../products/domain/entities/seller_product.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../domain/expiry_reminder.dart';
import 'alert_controller.dart';
import 'alert_scheduler.dart';
import 'notification_service.dart';

/// handle tap on notification
void onDidReceiveNotificationResponse(NotificationResponse response) async {
  if (response.payload == null) return;
  final sellerProductId = response.payload!;

  final detatailsScreen = ProductDetailsScreen(productId: sellerProductId);
  await navigatorKey.currentState
      ?.push(MaterialPageRoute(builder: (_) => detatailsScreen));
}

class AlertService {
  AlertService(this.settingsRepo, this.alertController, this._notifications);

  final SettingsRepository settingsRepo;
  final AlertController alertController;
  final NotificationService _notifications;

  Future<void> initialize() async {
    await PermissionsService.requestNotification();
    await _notifications.initialize();
  }

  Future<void> scheduleProductAlerts(SellerProduct product) async {
    final result = await settingsRepo.getSettings();
    if (!result.enableNotifications) return;

    if (product.expiryDate == null) return;

    final alerts = [
      ExpiryReminder(daysBefore: 30, importance: Priority.high),
      ExpiryReminder(daysBefore: 15, importance: Priority.high),
      ExpiryReminder(daysBefore: 7, importance: Priority.max),
      ExpiryReminder(daysBefore: 0, importance: Priority.max),
    ];

    final isExpired = DateTimeUtils.isExpired(product.expiryDate)!;

    for (final alert in alerts) {
      final days = alert.daysBefore;
      final importance = alert.importance;
      final isNearExpired =
          DateTimeUtils.isNearExpiry(product.expiryDate!, days);

      final isAlertDuplicated = await alertController.isAlertDuplicated(
        productId: product.id!,
        expiryDate: product.expiryDate!,
        daysBeforeExpiry: days,
      );

      if (isAlertDuplicated) continue;
      if (!isNearExpired && !isExpired) continue;

      await _scheduleAlert(
        product: product,
        daysBefore: days,
        importance: importance,
      );
    }
  }

  Future<void> _showNotification({
    required SellerProduct product,
    required int daysBefore,
    required Priority importance,
  }) async {
    final payload = product.id?.toString();

    await _notifications.show(
      id: AlertUtils.notificationId(product, daysBefore),
      title: 'تنبيه صلاحية: ${product.globalProduct.name}',
      body:
          '${product.globalProduct.name} ${daysBefore == 0 ? "منتهي" : "سينتهي خلال $daysBefore أيام"}',
      payload: payload,
    );

    await alertController.addAlert(
      product: product,
      daysBeforeExpiry: daysBefore,
      importance: importance,
    );
  }

  Future<void> _scheduleAlert({
    required SellerProduct product,
    required int daysBefore,
    required Priority importance,
  }) async {
    if (product.expiryDate == null) return;
    final alertDate = product.expiryDate!.subtract(Duration(days: daysBefore));

    if (alertDate.isBefore(DateTime.now())) {
      // إذا كان التاريخ في الماضي، أرسل التنبيه فورًا
      await _showNotification(
        product: product,
        daysBefore: daysBefore,
        importance: importance,
      );
      return;
    }
    final payload = product.id?.toString();

    await _notifications.schedule(
      id: AlertUtils.notificationId(product, daysBefore),
      title: 'تنبيه صلاحية',
      body:
          '${product.globalProduct.name} ${daysBefore == 0 ? "منتهي" : "سينتهي خلال $daysBefore أيام"}',
      date: alertDate,
      payload: payload,
    );

    final delay = alertDate.difference(DateTime.now());
    await scheduleWorkManagerAlert(product, daysBefore, delay);
  }

  Future<void> cancelProductAlerts(SellerProduct product) async {
    final daysList = {30, 15, 7, 0};

    for (final daysBefore in daysList) {
      final notificationId = AlertUtils.notificationId(product, daysBefore);
      await _notifications.cancel(notificationId);
    }
  }
}
