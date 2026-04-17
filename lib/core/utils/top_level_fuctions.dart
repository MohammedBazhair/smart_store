import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../app_initializer.dart';
import '../../features/alerts/data/models/alert_background_params.dart';
import '../constants/app_constants.dart';
import '../constants/enums.dart';
import '../database/local/cache_service.dart';
import 'background_utils.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName.isEmpty) return Future.value(false);

    AppProviders.container = await configureDependencies();

    final container = AppProviders.container;

    final tasksUtils = BackgroundUtils(container);
    try {
      final task = BackgroundTask.values.byName(taskName);

      switch (task) {
        case BackgroundTask.checkDailyExpiry:
          await tasksUtils.dailyExpiryCheck();

        case BackgroundTask.addProductAlert:
          if (inputData?.isEmpty ?? true) return Future.value(false);

          final backgroundParams = AlertBackgroundParams.fromMap(inputData!);

          if (backgroundParams.product.globalProduct.id == null) {
            return Future.value(false);
          }

          await tasksUtils.addAlertInBackground(backgroundParams);
        case BackgroundTask.syncAllData:
          await tasksUtils.syncAllData();
        case BackgroundTask.removeOldAlerts:
          await tasksUtils.removeOldAlerts();
      }
    } catch (e) {
      return Future.value(false);
    } finally {
      container.dispose();
    }
    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
  NotificationResponse details,
) async {
  final productId = details.payload;
  if (productId == null || productId.isEmpty) return;

  final _prefs = await SharedPreferences.getInstance();
  final localCache = LocalCacheServiceImpl(_prefs);
  await localCache.setString(
    key: AppConstants.pendingNotificationPayloadKey,
    value: productId,
  );
}
