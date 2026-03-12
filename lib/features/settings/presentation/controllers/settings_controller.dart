import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/log.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/result.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/entities/currence_code.dart';
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

  Future<void> refreshSettings() async {
    final repo = ref.read(storeRepositoryProvider);
    final userPhone = ref.watch(userControllerProvider).profile.phone!;
    await repo.syncAll(userPhone);

    final settings = await _getSettings();
    state = AsyncData(settings);
  }

  /// Returns:
  /// - `SuccessState(true)`  → currency changed successfully.
  /// - `SuccessState(false)` → selected currency is already the default (no update).
  /// - `ErrorState`          → an error occurred while updating.
  Future<Result<bool>> changeDefaultCurrency(CurrencyCode currency) async {
    try {
      if (state.value?.defaultCurrency == currency) {
        return const SuccessState(false);
      }

      final storeId = ref.read(storeControllerProvider).state.selectedStoreId!;
      final repository = ref.read(settingsRepositoryProvider);
      await repository.changeDefaultCurrency(
        currency: currency,
        storeId: storeId,
      );
      
      final settings = state.requireValue.copyWith(defaultCurrency: currency);
      await updateSettings(settings);
      return const SuccessState(true);
    } catch (e) {
      Logger.debugLog(error: e);
      return const ErrorState('حصلت مشكلة أثناء تحديث العملة حاول مرة اخرى');
    }
  }

  Future<Result<void>> updateSettings(Settings settings) async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final result = await repository.updateSettings(settings);

      if (result is SuccessState<void>) {
        state = AsyncValue.data(settings);
      }
      return result;
    } catch (e) {
      return ErrorState(e.toString());
    }
  }
}
