import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../app_initializer.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../core/utils/date_utils.dart';
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

  InitializationSettings get initializationSettings =>
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      
  Future<void> initialize() async {
    await Future.wait([
      DateTimeUtils.initializeTimezone(),
      _notifications.initialize(
        settings: initializationSettings,
        // onDidReceiveBackgroundNotificationResponse:
        // onDidReceiveBackgroundNotificationResponse,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      ),
    ]);

    await _handleNotificationAppLaunch();
  }

  Future<void> _handleNotificationAppLaunch() async {
    final details = await _notifications.getNotificationAppLaunchDetails();
    final isNotificationLaunch = details?.didNotificationLaunchApp ?? false;
    final payload = details?.notificationResponse?.payload;
    if (!isNotificationLaunch || payload == null || payload.isEmpty) return;

    final container = await AppProviders.container;

    final cache =container.read(localCacheServiceProvider);
    await cache.setString(
      key: AppConstants.pendingNotificationPayloadKey,
      value: payload,
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
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(date, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  /// إلغاء إشعار
  Future<void> cancel(int id) async {
    await _notifications.cancel(id: id);
  }
}
