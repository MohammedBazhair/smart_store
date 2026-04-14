import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/top_level_fuctions.dart';
import '../../features/alerts/presentation/controllers/alert_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/database/local/database_helper.dart';
import 'core/extensions/extensions.dart';
import 'core/shared/providers/core_providers.dart';
import 'core/shared/providers/repositories_provider.dart';
import 'features/products/presentation/controllers/product_provider.dart';
import 'features/products/presentation/screens/init_screen.dart';
import 'features/products/presentation/screens/product_details_screen.dart';
import 'main.dart';

class AppProviders {
  AppProviders._();
  static late ProviderContainer container;
}

Future<ProviderContainer> configureDependencies() async {
  final results = await Future.wait([
    initializeDateFormatting('ar'),
    initializeSupabase(),
    SharedPreferences.getInstance(),
    DatabaseHelper.instance.database,
  ]);

  final sharedPrefs = results[2] as SharedPreferences;
  final database = results[3] as Database;

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
  await Future.wait([
    _initializeAlertService(container),
    _initializeWorkManager(),
    _initializePushNotification(),
  ]);
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
    BackgroundTask.checkDailyExpiry.name,
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );

  await Workmanager().registerPeriodicTask(
    'syncAllDataTask',
    BackgroundTask.syncAllData.name,
    frequency: const Duration(hours: 2),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
    constraints: Constraints(networkType: NetworkType.connected),
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
    final productId = notification.additionalData?['product_id']?.toString();

    if (notification.title?.contains('تم تفعيل حسابك') ?? false) {
      await navigatorKey.currentContext?.pushAndRemoveUntilTo(const InitScreen());
      return;
    }

    if (productId != null) {
      final container = AppProviders.container;
      final cache = container.read(localCacheServiceProvider);
      await cache.setString(
        key: AppConstants.pendingNotificationPayloadKey,
        value: productId,
      );

      if (navigatorKey.currentState != null) {
        container.read(currentProductIdProvider.notifier).state = productId;
        await navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ProductDetailsScreen()),
        );
      }
    }
  });
}
