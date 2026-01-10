import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../domain/settings.dart';

/// Provider للحصول على الإعدادات
final appSettingsProvider = FutureProvider<Settings>((ref) async {
  final repository = ref.read(settingsRepositoryProvider);
  final result = await repository.getSettings();

  return result;
});
