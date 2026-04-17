import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_initializer.dart';
import 'core/constants/log.dart';
import 'core/shared/presentation/screen/smart_store_app.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _tryRunMain() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  AppProviders.container = await configureDependencies();

  runApp(
    UncontrolledProviderScope(
      container: AppProviders.container,
      child: const SmartStoreApp(),
    ),
  );

  // Remove splash after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

Future<void> main() async {
  try {
    await _tryRunMain();
  } catch (e, stack) {
    Logger.debugLog(error: e, stackTrace: stack);

    FlutterNativeSplash.remove();
    await _tryRunMain();
  }
}
