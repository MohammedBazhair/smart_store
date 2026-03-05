import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../errors/result.dart';
import '../../domain/entities/settings.dart';
import 'settings_provider.dart';

class SettingsController extends AsyncNotifier<Settings> {
  @override
  Future<Settings> build() {
    return _getSettings();
  }

  Future<Settings> _getSettings() {
    final repository = ref.read(settingsRepositoryProvider);
    return repository.getSettings();
  }

  Future<Result<void>> updateSettings(Settings settings) async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final result = await repository.updateSettings(settings);

      if (result is SuccessState<void>) {
        state = AsyncValue.data(settings);
      }
      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }
}
