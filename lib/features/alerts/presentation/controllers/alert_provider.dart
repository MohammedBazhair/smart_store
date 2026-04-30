import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import 'alert_service.dart';
import 'alerts_controller.dart';
import 'alerts_state.dart';
import 'notification_service.dart';

final alertServiceProvider = Provider<AlertService>((ref) {
  final settingsRepository = ref.read(settingsRepositoryProvider);
  final controller = ref.read(alertsControllerProvider.notifier);
  final alertRepository = ref.read(alertRepositoryProvider);
  final notification = ref.read(notificationServiceProvider);

  return AlertService(
    settingsRepository,
    alertRepository,
    notification,
    controller,
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Provider للـ AlertController
final alertsControllerProvider =
    NotifierProvider<AlertsController, AlertsState>(() {
  return AlertsController();
});
