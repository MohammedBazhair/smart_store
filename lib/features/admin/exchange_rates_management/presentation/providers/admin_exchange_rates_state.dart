import '../../../../settings/domain/entities/currence_code.dart';
import '../../../../settings/domain/entities/exchange_rate.dart';

class AdminExchangeRatesState {
  const AdminExchangeRatesState({
    this.isLoading = false,
    this.rates = const {},
  });
  final bool isLoading;
  final Map<CurrencyCode,ExchangeRate> rates;

  AdminExchangeRatesState copyWith({
    bool? isLoading,
    Map<CurrencyCode, ExchangeRate>? rates,
  }) {
    return AdminExchangeRatesState(
      isLoading: isLoading ?? this.isLoading,
      rates: rates ?? this.rates,
    );
  }
}
