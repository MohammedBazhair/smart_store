import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../../products/domain/product.dart';
import '../../../settings/domain/settings.dart';
import '../../../settings/domain/settings_repository.dart';
import 'alert_controller.dart';

final alertServiceProvider = Provider<AlertService>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  final controller = ref.read(alertControllerProvider.notifier);

  return AlertService(repository, controller);
});

// top-level function
@pragma('vm:entry-point')
void notificationBackground(NotificationResponse details) {
  print('Background notification received!');
  print(details.payload);
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
      print('currentZone: $currentZone');
    } catch (e) {
      print(e);
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
      onDidReceiveBackgroundNotificationResponse: notificationBackground ,
      onDidReceiveNotificationResponse: (details) {
        // TODO: Handle notification tap
        print('---------- tap -----------');
        print(details.payload);
        print('---------- tap -----------');
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

    final daysUntilExpiry = DateUtils.daysUntilExpiry(product.expiryDate);

    // تنبيه قبل 30 يوم
    if (daysUntilExpiry <= settings.alertDays30 &&
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
    final alertDate = product.expiryDate.subtract(Duration(days: daysBefore));

    if (alertDate.isBefore(DateTime.now())) {
      // إذا كان التاريخ في الماضي، أرسل التنبيه فورًا
      await _showNotification(
        product: product,
        daysBefore: daysBefore,
        importance: importance,
      );
    } else {
      // جدولة التنبيه
      await _notifications.zonedSchedule(
        _notificationId(product, daysBefore),
        'تنبيه صلاحية',
        '${product.name} ${daysBefore == 0 ? "منتهي" : "سينتهي خلال $daysBefore أيام"}',
        tz.TZDateTime.from(alertDate, tz.local),
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // إضافة التنبيه إلى قاعدة البيانات
      await controller.addAlert(
        product: product,
        daysBeforeExpiry: daysBefore,
        importance: importance,
      );
    }
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

  Future<void> testScheduledNotification() async {
    final date = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    try {
      await _notifications.zonedSchedule(
        9999,
        '⏰ اختبار جدولة',
        'سيظهر بعد 5 ثواني',
        date,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_schedule',
            'اختبار الجدولة',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '10|7',
      );
    } catch (e) {
      print(e);
    }
  }
}
