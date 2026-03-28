import 'dart:io' show Platform;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../errors/result.dart';

class PermissionsService {
  static Future<Result<bool>> requestCamera() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        return const SuccessState(true);
      }

      if (status.isPermanentlyDenied) {
        await AppSettings.openAppSettings(type: AppSettingsType.camera);
      }
      
      return const SuccessState(false);
    } on MissingPluginException catch (e) {
      final result = await openAppSettings();
      return result ? SuccessState(result) : ErrorState(e.toString());
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  static Future<Result<bool>> requestNotification() async {
    try {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        return const SuccessState(true);
      }

      if (status.isPermanentlyDenied) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
      }
      return const SuccessState(false);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  /// Android: whether the app is exempt from battery optimization (best-effort).
  /// Other platforms: always true (no equivalent flow).
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Android: shows the system dialog to allow ignoring battery optimizations.
  static Future<Result<bool>> requestIgnoreBatteryOptimizations() async {
    try {
      if (kIsWeb || !Platform.isAndroid) {
        return const SuccessState(true);
      }

      final status = await Permission.ignoreBatteryOptimizations.request();
      if (status.isGranted) {
        return const SuccessState(true);
      }

      if (status.isPermanentlyDenied) {
        await AppSettings.openAppSettings(
          type: AppSettingsType.batteryOptimization,
        );
      }

      return const SuccessState(false);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  /// Android: opens the battery optimization / related settings screen.
  static Future<void> openBatteryOptimizationSettings() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await AppSettings.openAppSettings(
      type: AppSettingsType.batteryOptimization,
    );
  }
}
