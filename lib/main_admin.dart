import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_initializer.dart';
import 'core/shared/domain/entities/flavor_app_type.dart';
import 'features/admin/presentation/admin_app.dart';

final adminNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await configureDependencies(FlavorAppType.admin);

  final container = await AppProviders.container;

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AdminApp(),
    ),
  );

  // Remove splash after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
