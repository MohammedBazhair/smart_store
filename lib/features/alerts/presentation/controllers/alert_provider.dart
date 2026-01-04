import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../domain/alert.dart';

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
