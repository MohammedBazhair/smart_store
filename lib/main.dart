import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';

import 'core/utils/permissions.dart';
import 'core/utils/result.dart';
import 'features/alerts/data/alert_background_params.dart';
import 'features/alerts/data/alert_repository_impl.dart';
import 'features/alerts/domain/alert.dart';
import 'features/alerts/presentation/controllers/alert_service.dart';
import 'features/dashboard/presentation/screen/dashboard_screen.dart';
import 'shared/presentation/theme/app_theme.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (inputData == null) return Future.value(false);

    final backgroundParams = AlertBackgroundParams.fromMap(inputData);

    if (backgroundParams.product.id == null) return Future.value(false);

    await addAlertInBackground(backgroundParams);

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ar');

  // إنشاء Container مؤقت للوصول إلى providers
  final container = ProviderContainer();

  // تهيئة خدمة التنبيهات
  final alertService = container.read(alertServiceProvider);
  await alertService.initialize();

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  final result = await PermissionsService.requestNotification();
  
  if (result is ErrorState<bool>) exit(0);

  if (result is SuccessState<bool> && !result.data) {
    exit(0);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SmartStoreApp(),
    ),
  );
}

class SmartStoreApp extends StatelessWidget {
  const SmartStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Smart Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}

Future<Result<int>> addAlertInBackground(AlertBackgroundParams params) {
  final product = params.product;
  final repository = AlertRepositoryImpl();
  final alert = Alert(
    productId: product.id!,
    daysBeforeExpiry: params.daysBeforeExpire,
    importance: Priority.high,
    isRead: false,
    createdAt: DateTime.now(),
    expiryDate: product.expiryDate,
    productName: product.name,
  );
  return repository.addAlert(alert);
}
