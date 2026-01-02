import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await AppSettings.openAppSettings(type: AppSettingsType.camera);
    }
    return false;
  }

  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
    return false;
  }
}
