import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../app_initializer.dart';
import '../../features/alerts/data/alert_background_params.dart';
import '../../features/alerts/presentation/controllers/notification_cache.dart';
import '../constants/enums.dart';
import '../database/local/database_helper.dart';
import '../shared/providers/core_providers.dart';
import '../shared/providers/repositories_provider.dart';
import 'background_utils.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName.isEmpty) return Future.value(false);

    // تهيئة ProviderContainer في الخلفية
    await initializeSupabase();
    final sharedPrefs = await SharedPreferences.getInstance();
    final database = await DatabaseHelper.instance.database;
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        databaseProvider.overrideWithValue(database),
      ],
    );

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

          await tasksUtils.addAlertInBackground( backgroundParams);
        case BackgroundTask.syncAllData:
          await tasksUtils.syncAllData();
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

  final productId = details.payload;
  if (productId == null) return;

  NotificationCache.save(productId);
}
