import 'package:equatable/equatable.dart';

import 'currence_code.dart';

class ExchangeRate extends Equatable {
  const ExchangeRate({
    required this.currency,
    required this.rateToBase,
    required this.updatedAt,
  });

  factory ExchangeRate.defaultRate() => ExchangeRate(
        currency: CurrencyCode.YER,
        rateToBase: 1,
        updatedAt: DateTime.now(),
      );

  final CurrencyCode currency;
  final int rateToBase;
  final DateTime updatedAt;


  @override
  String toString() =>
      'ExchangeRate(currency: $currency, rateToBase: $rateToBase, updatedAt: $updatedAt)';

  @override
  List<Object?> get props => [rateToBase,  currency];
}
