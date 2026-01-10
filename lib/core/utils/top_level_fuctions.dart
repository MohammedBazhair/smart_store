import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/alerts/data/alert_background_params.dart';
import '../../features/alerts/presentation/controllers/notification_cache.dart';
import '../constants/enums.dart';
import 'background_utils.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName.isEmpty) return Future.value(false);
    final tasksUtils = BackgroundUtils();
    try {
      final task = BackgroundTask.values.byName(taskName);

      switch (task) {
        case BackgroundTask.dailyExpiryCheck:
          await tasksUtils.dailyExpiryCheck();

        case BackgroundTask.addAlertForProduct:
          if (inputData?.isEmpty ?? true) return Future.value(false);

          final backgroundParams = AlertBackgroundParams.fromMap(inputData!);

          if (backgroundParams.product.id == null) return Future.value(false);

          await tasksUtils.addAlertInBackground(backgroundParams);
      }
    } catch (e) {
      return Future.value(false);
    }
    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse details) {
  if (details.payload?.isEmpty ?? true) return;

  final productId = int.tryParse(details.payload!);
  if (productId == null) return;

  NotificationCache.save(productId);
}
