import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../errors/result.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../domain/settings.dart';
import 'settings_provider.dart';

/// Controller لإدارة الإعدادات
class SettingsController extends Notifier<void> {
  @override
  void build() {}

  /// تحديث الإعدادات
  Future<Result<void>> updateSettings(Settings settings) async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final result = await repository.updateSettings(settings);

      if (result is SuccessState<void>) {
        // تحديث provider الإعدادات
        ref.invalidate(appSettingsProvider);
      }
      return result;
    } catch (e) {

      return ErrorState(e.toString());
    }
  }
}

/// Provider للـ SettingsController
final settingsControllerProvider =
    NotifierProvider<SettingsController, void>(() {
  return SettingsController();
});
