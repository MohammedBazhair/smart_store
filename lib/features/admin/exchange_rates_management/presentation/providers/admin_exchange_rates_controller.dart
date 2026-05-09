import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/log.dart';
import '../../../../../core/shared/providers/ui_providers.dart';
import '../../../../settings/domain/entities/exchange_rate.dart';
import '../../data/admin_exchange_rates_repository.dart';
import 'admin_exchange_rates_provider.dart';
import 'admin_exchange_rates_state.dart';

class AdminExchangeRatesController extends Notifier<AdminExchangeRatesState> {
  AdminExchangeRatesRepository get _repository =>
      ref.read(adminExchangeRatesRepositoryProvider);

  @override
  AdminExchangeRatesState build() {
    return const AdminExchangeRatesState();
  }

  Future<void> fetchExchangeRates() async {
    try {
      state = state.copyWith(
        isLoading: true,
      );

      final rates = await _repository.getAllExchangeRates();

      final ratesMap = {
        for (final r in rates) r.currency: r,
      };
      state = state.copyWith(
        isLoading: false,
        rates: ratesMap,
      );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);

      ref.read(appUiEventProvider.notifier).showError(
            e.toString(),
          );

      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> updateRate({
    required ExchangeRate rate,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
      );

      final updatedRate = await _repository.updateRateBase(rate);

      final copiedRates = {...state.rates};

      copiedRates[rate.currency] = updatedRate;

      state = state.copyWith(
        isLoading: false,
        rates: copiedRates,
      );

      ref.read(appUiEventProvider.notifier).showSuccess(
            'تم تحديث بيانات العملة ${updatedRate.currency} بنجاح',
          );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);

      ref.read(appUiEventProvider.notifier).showError(
            e.toString(),
          );

      state = state.copyWith(
        isLoading: false,
      );
    }
  }
}
