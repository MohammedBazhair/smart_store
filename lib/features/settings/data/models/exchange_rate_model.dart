import '../../domain/entities/exchange_rate.dart';

class ExchangeRateModel extends ExchangeRate {
  const ExchangeRateModel({
    required super.currency,
    required super.rateToBase,
    required super.updatedAt,
  });

  factory ExchangeRateModel.fromMap(Map<String, dynamic> map) {
    return ExchangeRateModel(
      currency: map['currency'],
      rateToBase: map['rate_to_base'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency.name,
      'rate_to_base': rateToBase,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}
