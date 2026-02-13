import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../errors/result.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../domain/alert.dart';
import 'alert_controller.dart';
import 'alert_service.dart';
import 'notification_service.dart';

/// Provider للحصول على جميع التنبيهات
final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  final repository = ref.watch(alertRepositoryProvider);
  final result = await repository.getAllAlerts();
  if (result is SuccessState<List<Alert>>) {
    return result.data;
  }
  return [];
});

final newAlertsProvider = FutureProvider<List<Alert>>((ref) async {
  final repository = ref.watch(alertRepositoryProvider);
  final result = await repository.getNewAlerts();
  if (result is SuccessState<List<Alert>>) {
    return result.data;
  }
  return [];
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
