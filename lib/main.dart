import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_initializer.dart';
import 'core/shared/presentation/screen/smart_store_app.dart';
import 'core/shared/providers/app_provider_class.dart';

final navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await configureDependencies();

  runApp(
    UncontrolledProviderScope(
      container: await AppProviders.container,
      child: const SmartStoreApp(),
    ),
  );

  // Remove splash after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
