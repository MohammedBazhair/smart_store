import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_initializer.dart';
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
    FlutterNativeSplash.remove();
    runApp(
      ErrorApp(
        error: e,
        stack: stack,
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({
    super.key,
    required this.error,
    required this.stack,
  });
  final Object error;
  final StackTrace stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              'ERROR:\n\n$error\n\nSTACK:\n\n$stack',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
