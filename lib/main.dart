import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/alerts/presentation/controllers/alert_service.dart';
import 'features/dashboard/presentation/screen/dashboard_screen.dart';
import 'shared/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await initializeDateFormatting('ar');

  // إنشاء Container مؤقت للوصول إلى providers
  final container = ProviderContainer();

  // تهيئة خدمة التنبيهات
  final alertService = container.read(alertServiceProvider);
  await alertService.initialize();

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
        Locale('en'), // الإنجليزية
        Locale('ar'), // العربية
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
