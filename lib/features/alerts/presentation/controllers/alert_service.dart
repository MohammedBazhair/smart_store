import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../../products/data/product_model.dart';
import '../../../products/domain/product.dart';
import '../../../settings/domain/settings.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../data/alert_background_params.dart';
import 'alert_controller.dart';

final alertServiceProvider = Provider<AlertService>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  final controller = ref.read(alertControllerProvider.notifier);

  return AlertService(repository, controller);
});

// top-level function
@pragma('vm:entry-point')
void notificationBackground(NotificationResponse details) {
  // TODO: notificationBackground
}

/// خدمة التنبيهات
class AlertService {
  AlertService(this.repository, this.controller);

  final SettingsRepository repository;
  final AlertController controller;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// تهيئة خدمة التنبيهات
  Future<void> initialize() async {
    await PermissionsService.requestNotification();
    // تهيئة الوقت
    tz.initializeTimeZones();
    const defaultTimezone = 'Asia/Aden';
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final currentZone = timezoneInfo.localizedName?.name ?? defaultTimezone;
      tz.setLocalLocation(tz.getLocation(currentZone));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation(defaultTimezone));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse: notificationBackground,
      onDidReceiveNotificationResponse: (details) {
        // TODO: Handle notification tap
      },
    );
  }

  /// إنشاء تنبيهات للمنتج
  Future<void> scheduleProductAlerts(
    Product product,
  ) async {
    await PermissionsService.requestNotification();

    final result = await repository.getSettings();
    if (result is! SuccessState<Settings>) return;
    final settings = result.data;

    if (!settings.enableNotifications) return;
    if (product.expiryDate == null) return;

    final daysUntilExpiry = DateUtils.daysUntilExpiry(product.expiryDate);

    // تنبيه قبل 30 يوم
    if (daysUntilExpiry !<= settings.alertDays30 &&
        daysUntilExpiry > settings.alertDays7) {
      await _scheduleAlert(
        product: product,
        daysBefore: settings.alertDays30,
        importance: Priority.defaultPriority,
      );
    }

    // تنبيه قبل 7 أيام
    if (daysUntilExpiry <= settings.alertDays7 &&
        daysUntilExpiry > settings.alertDays1) {
      await _scheduleAlert(
        product: product,
        daysBefore: settings.alertDays7,
        importance: Priority.high,
      );
    }

    // تنبيه قبل يوم واحد
    if (daysUntilExpiry <= settings.alertDays1 && daysUntilExpiry > 0) {
      await _scheduleAlert(
        product: product,
        daysBefore: settings.alertDays1,
        importance: Priority.high,
      );
    }

    // تنبيه عند الانتهاء
    if (daysUntilExpiry <= 0) {
      await _scheduleAlert(
        product: product,
        daysBefore: 0,
        importance: Priority.high,
      );
    }
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
    final scheduleDate = tz.TZDateTime.from(alertDate, tz.local);
    // جدولة التنبيه
    await _notifications.zonedSchedule(
      _notificationId(product, daysBefore),
      'تنبيه صلاحية',
      '${product.name} ${daysBefore == 0 ? "منتهي" : "سينتهي خلال $daysBefore أيام"}',
      scheduleDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'product_alerts',
          'تنبيهات المنتجات',
          channelDescription: 'تنبيهات صلاحية المنتجات',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final delay = scheduleDate.difference(DateTime.now());
    final productModel = ProductModel.fromEntity(product);
    final alertParams = AlertBackgroundParams(
      product: productModel,
      daysBeforeExpire: daysBefore,
    );
    await Workmanager().registerOneOffTask(
      '${product.id}',
      'AlertProduct',
      initialDelay: delay,
      inputData: alertParams.toMap(),
    );
  }

  int _notificationId(Product product, int daysBefore) {
    return product.id.hashCode ^ daysBefore;
  }

  Future<void> _showNotification({
    required Product product,
    required int daysBefore,
    required Priority importance,
  }) async {
    await _notifications.show(
      _notificationId(product, daysBefore),
      'تنبيه صلاحية',
      '${product.name} ${daysBefore == 0 ? "منتهي" : "سينتهي خلال $daysBefore أيام"}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'product_alerts',
          'تنبيهات المنتجات',
          channelDescription: 'تنبيهات صلاحية المنتجات',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    // إضافة التنبيه إلى قاعدة البيانات
    await controller.addAlert(
      product: product,
      daysBeforeExpiry: daysBefore,
      importance: importance,
    );
  }

  Future<void> cancelProductAlerts(Product product) async {
    final settingsResult = await repository.getSettings();
    if (settingsResult is! SuccessState<Settings>) return;

    final settings = settingsResult.data;

    final daysList = <int>{
      settings.alertDays30,
      settings.alertDays7,
      settings.alertDays1,
      0, // تنبيه الانتهاء
    };

    for (final daysBefore in daysList) {
      await _notifications.cancel(
        _notificationId(product, daysBefore),
      );
    }
  }
}
