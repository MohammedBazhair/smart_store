import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/utils/alert_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../core/utils/result.dart';
import '../../../../main.dart';
import '../../../products/data/product_model.dart';
import '../../../products/data/product_repository_impl.dart';
import '../../../products/domain/product.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../domain/expiry_reminder.dart';
import 'alert_controller.dart';
import 'alert_scheduler.dart';
import 'notification_service.dart';

/// handle tap on notification
void onDidReceiveNotificationResponse(NotificationResponse response) async {
  if (response.payload == null) return;
  final rawString = response.payload!;
  final product = ProductModel.fromJson(rawString);

  final productId = product.id;
  if (productId == null) return;

  final repo = ProductRepositoryImpl();
  final result = await repo.getProductById(productId);

  switch (result) {
    case SuccessState<Product>():
      final detatailsScreen = ProductDetailsScreen(productId: productId);
      await navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => detatailsScreen));
    case ErrorState<Product>():
  }
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

  Future<void> scheduleProductAlerts(Product product) async {
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
    required Product product,
    required int daysBefore,
    required Priority importance,
  }) async {
    final payload = product.id?.toString();

    await _notifications.show(
      id: AlertUtils.notificationId(product, daysBefore),
      title: 'تنبيه صلاحية: ${product.name}',
      body:
          '${product.name} ${daysBefore == 0 ? "منتهي" : "سينتهي خلال $daysBefore أيام"}',
      payload: payload,
    );

    await alertController.addAlert(
      product: product,
      daysBeforeExpiry: daysBefore,
      importance: importance,
    );
  }

  Future<void> _scheduleAlert({
    required Product product,
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
          '${product.name} ${daysBefore == 0 ? "منتهي" : "سينتهي خلال $daysBefore أيام"}',
      date: alertDate,
      payload: payload,
    );

    final delay = alertDate.difference(DateTime.now());
    await scheduleWorkManagerAlert(product, daysBefore, delay);
  }

  Future<void> cancelProductAlerts(Product product) async {
    final daysList = {30, 15, 7, 0};

    for (final daysBefore in daysList) {
      final notificationId = AlertUtils.notificationId(product, daysBefore);
      await _notifications.cancel(notificationId);
    }
  }
}
