import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';

import 'core/constants/enums.dart';
import 'core/screen/smart_store_app.dart';
import 'core/utils/top_level_fuctions.dart';
import 'features/alerts/presentation/controllers/alert_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final container = ProviderContainer();

  await _setupMain(container);
}

Future<void> _setupMain(ProviderContainer container) async {
  await initializeDateFormatting('ar');

  final alertService = container.read(alertServiceProvider);
  await alertService.initialize();

  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    'dailyExpiryTask',
    BackgroundTask.dailyExpiryCheck.name,
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );



  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SmartStoreApp(),
    ),
  );
}
