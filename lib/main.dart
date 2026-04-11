import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_initializer.dart';
import 'core/shared/presentation/screen/smart_store_app.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  AppProviders.container = await configureDependencies();

  FlutterNativeSplash.remove();
  runApp(
    UncontrolledProviderScope(
      container: AppProviders.container,
      child: const SmartStoreApp(),
    ),
  );
}
