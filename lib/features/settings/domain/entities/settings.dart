import 'package:equatable/equatable.dart';
import 'currence_code.dart';
import 'exchange_rate.dart';

class Settings extends Equatable {
  const Settings({
    required this.defaultCurrency,
    required this.enableNotifications,
    required this.exchagneRates,
  });

  factory Settings.theDefault(List<ExchangeRate> exchangeRates) {
    return Settings(
      defaultCurrency: CurrencyCode.YER,
      enableNotifications: true,
      exchagneRates: exchangeRates,
    );
  }

  final CurrencyCode defaultCurrency;
  final bool enableNotifications;
  final List<ExchangeRate> exchagneRates;

  ExchangeRate get defaultExchangeRate {
    try {
      final result =
          exchagneRates.firstWhere((e) => e.currency == defaultCurrency);

      return result;
    } catch (e) {
      return ExchangeRate(
        currency: CurrencyCode.theDefault,
        rateToBase: 1,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  List<Object?> get props =>
      [defaultCurrency, enableNotifications, exchagneRates];

  Settings copyWith({
    CurrencyCode? defaultCurrency,
    bool? enableNotifications,
    List<ExchangeRate>? exchagneRates,
  }) {
    return Settings(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      exchagneRates: exchagneRates ?? this.exchagneRates,
    );
  }
}
