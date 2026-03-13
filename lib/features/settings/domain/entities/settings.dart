import 'package:equatable/equatable.dart';

import '../../../../core/constants/log.dart';
import 'currence_code.dart';
import 'exchange_rate.dart';

class Settings extends Equatable {
  const Settings({
    required this.defaultCurrency,
    required this.enableNotifications,
    required this.exchageRates,
  });

  factory Settings.theDefault(List<ExchangeRate> exchangeRates) {
    return Settings(
      defaultCurrency: CurrencyCode.YER,
      enableNotifications: true,
      exchageRates: exchangeRates,
    );
  }

  final CurrencyCode defaultCurrency;
  final bool enableNotifications;
  final List<ExchangeRate> exchageRates;

  ExchangeRate get defaultExchangeRate {
    try {
      final result =
          exchageRates.firstWhere((e) => e.currency == defaultCurrency);

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
      [defaultCurrency, enableNotifications, exchageRates];

  Settings copyWith({
    CurrencyCode? defaultCurrency,
    bool? enableNotifications,
    List<ExchangeRate>? exchageRates,
  }) {
    return Settings(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      exchageRates: exchageRates ?? this.exchageRates,
    );
  }
}
