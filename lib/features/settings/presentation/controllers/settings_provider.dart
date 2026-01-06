import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../domain/settings.dart';

/// Provider للحصول على الإعدادات
final appSettingsProvider = FutureProvider<Settings>((ref) async {
  final repository = ref.read(settingsRepositoryProvider);
  final result = await repository.getSettings();
  if (result is SuccessState<Settings>) {
    return result.data;
  } else if (result is ErrorState<Settings>) {
    throw Exception(result.message);
  }
  throw Exception('خطأ غير معروف');
});
