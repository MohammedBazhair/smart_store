import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/utils/top_level_fuctions.dart';
import 'alert_service.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationDetails get notificationDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          'product_alerts',
          'تنبيهات المنتجات',
          channelDescription: 'تنبيهات صلاحية المنتجات',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const defaultTimezone = 'Asia/Aden';
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final currentZone = timezoneInfo.localizedName?.name ?? defaultTimezone;
      tz.setLocalLocation(tz.getLocation(currentZone));
    } catch (_) {
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
      settings: initSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  /// عرض إشعار فوري
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// جدولة إشعار
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
     id:  id,
     title:  title,
     body:  body,
     scheduledDate: tz.TZDateTime.from(date, tz.local),
    notificationDetails:   notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// إلغاء إشعار
  Future<void> cancel(int id) async {
    await _notifications.cancel(id:  id);
  }
}
