import 'currence_code.dart';

class ExchangeRate {
  const ExchangeRate({
    required this.currency,
    required this.rateToBase,
    required this.updatedAt,
  });
  final CurrencyCode currency;
  final int rateToBase;
  final DateTime updatedAt;
}
