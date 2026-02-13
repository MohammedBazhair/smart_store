import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/alerts/data/alert_background_params.dart';
import '../../features/alerts/presentation/controllers/notification_cache.dart';
import '../constants/enums.dart';
import '../shared/providers/repositories_provider.dart';
import 'background_utils.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName.isEmpty) return Future.value(false);

    // تهيئة ProviderContainer في الخلفية
    final sharedPrefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
    );

    final tasksUtils = BackgroundUtils();
    try {
      final task = BackgroundTask.values.byName(taskName);

      switch (task) {
        case BackgroundTask.dailyExpiryCheck:
          await tasksUtils.dailyExpiryCheck(container);

        case BackgroundTask.addAlertForProduct:
          if (inputData?.isEmpty ?? true) return Future.value(false);

          final backgroundParams = AlertBackgroundParams.fromMap(inputData!);

          if (backgroundParams.product.id == null) return Future.value(false);

          await tasksUtils.addAlertInBackground(container, backgroundParams);
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
void onDidReceiveBackgroundNotificationResponse(NotificationResponse details) {
  if (details.payload?.isEmpty ?? true) return;

  final productId = int.tryParse(details.payload!);
  if (productId == null) return;

  NotificationCache.save(productId);
}
