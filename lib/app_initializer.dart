import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/top_level_fuctions.dart';
import '../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../shared/providers/repositories_provider.dart';

Future<ProviderContainer> configureDependencies() async {
  await initializeDateFormatting('ar');

  final sharedPrefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    ],
  );

  await _initializeServices(container);

  return container;
}

Future<void> _initializeServices(ProviderContainer container) async {
  await _initializeAlertService(container);
  await _initializeWorkManager();
  await _initializeSupabase();
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
