import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../../domain/alert.dart';
import 'alert_controller.dart';
import 'alert_service.dart';
import 'notification_service.dart';

/// Provider للحصول على جميع التنبيهات
final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  final repository = ref.watch(alertRepositoryProvider);
  final result = await repository.getAllAlerts();

  return result;
});

final newAlertsProvider = FutureProvider<List<Alert>>((ref) async {
  final repository = ref.watch(alertRepositoryProvider);
  final result = await repository.getNewAlerts();
  return result;
});

final alertServiceProvider = Provider<AlertService>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  final controller = ref.read(alertControllerProvider.notifier);
  final notification = ref.read(notificationServiceProvider);

  return AlertService(repository, controller, notification);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Provider للـ AlertController
final alertControllerProvider =
    NotifierProvider<AlertController, AlertsState>(() {
  return AlertController();
});
