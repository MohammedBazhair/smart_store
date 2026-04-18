import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/top_level_fuctions.dart';
import '../../features/alerts/presentation/controllers/alert_provider.dart';
import 'core/extensions/extensions.dart';
import 'core/shared/providers/app_provider_class.dart';
import 'features/products/presentation/screens/init_screen.dart';
import 'main.dart';

Future<void> configureDependencies() async {
  await Future.wait([
    _initializeAlertService(),
    _initializeWorkManager(),
    _initializePushNotification(),
  ]);
}

Future<void> _initializeAlertService() async {
  final container = await AppProviders.container;
  final alertService = container.read(alertServiceProvider);
  await alertService.initialize();
}

Future<void> _initializeWorkManager() async {
  await Workmanager().initialize(callbackDispatcher);
  await _registerBackgroundTasks();
}

Future<void> _registerBackgroundTasks() async {
  await Workmanager().registerPeriodicTask(
    'dailyExpiryTask',
    BackgroundTask.checkDailyExpiry.name,
    frequency: const Duration(days: 1),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );

  await Workmanager().registerPeriodicTask(
    'syncAllDataTask',
    BackgroundTask.syncAllData.name,
    frequency: const Duration(hours: 3),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  await Workmanager().registerPeriodicTask(
    'removeOldAlertsTask',
    BackgroundTask.removeOldAlerts.name,
    frequency: const Duration(days: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );
}

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'https://btesmjmzmgkjyljfxsxx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0ZXNtam16bWdranlsamZ4c3h4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4NjkyMDYsImV4cCI6MjA4NjQ0NTIwNn0.08YQFFWzFFb43EA1torB_ckO3xw4SgeWVpYraftKpyc',
  );
}

Future<void> _initializePushNotification() async {
  // Enable verbose logging for debugging (remove in production)
  await OneSignal.Debug.setLogLevel(OSLogLevel.none);
  // Initialize with your OneSignal App ID
  OneSignal.initialize('4a72759f-2beb-4621-80ed-7ee6b9bfc813');

  OneSignal.Notifications.addClickListener((event) async {
    final notification = event.notification;

    if (notification.title?.contains('تم تفعيل حسابك') ?? false) {
      if (navigatorKey.currentContext != null) {
        await navigatorKey.currentContext
            ?.pushAndRemoveUntilTo(const InitScreen());
      }
      return;
    }
  });
}
