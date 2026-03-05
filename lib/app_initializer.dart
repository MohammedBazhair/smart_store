import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/top_level_fuctions.dart';
import '../../features/alerts/presentation/controllers/alert_provider.dart';
import 'core/database/local/database_helper.dart';
import 'core/extensions/extensions.dart';
import 'core/shared/providers/core_providers.dart';
import 'core/shared/providers/repositories_provider.dart';
import 'features/products/presentation/screens/init_screen.dart';
import 'main.dart';

Future<ProviderContainer> configureDependencies() async {
  await initializeDateFormatting('ar');
  await _initializeSupabase();

  final sharedPrefs = await SharedPreferences.getInstance();
  final database = await DatabaseHelper.instance.database;
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      databaseProvider.overrideWithValue(database),
    ],
  );

  await _initializeServices(container);

  return container;
}

Future<void> _initializeServices(ProviderContainer container) async {
  await _initializeAlertService(container);
  await _initializeWorkManager();
  await _initializePushNotification();
}

Future<void> _initializeAlertService(
  ProviderContainer container,
) async {
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
    BackgroundTask.dailyExpiryCheck.name,
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );
}

Future<void> _initializeSupabase() async {
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

  OneSignal.Notifications.addClickListener((event) {
    final notification = event.notification;

    if (notification.title?.contains('تم تفعيل حسابك') ?? false) {
      navigatorKey.currentContext?.pushAndRemoveUntilTo(const InitScreen());
    }
  });
}
