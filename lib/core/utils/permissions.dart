import 'package:app_settings/app_settings.dart';
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
}
