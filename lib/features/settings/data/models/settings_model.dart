import 'dart:convert';
import '../../domain/entities/currence_code.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/entities/settings.dart';

class SettingsModel extends Settings {
  const SettingsModel({
    required super.defaultCurrency,
    required super.enableNotifications,
    required super.exchageRates,
  });

  factory SettingsModel.fromJson(
    String source,
    List<ExchangeRate> exchangeRates,
  ) {
    final map = jsonDecode(source);
    return SettingsModel.fromMap(map, exchangeRates);
  }

  factory SettingsModel.fromEntity(Settings settings) {
    return SettingsModel(
      defaultCurrency: settings.defaultCurrency,
      enableNotifications: settings.enableNotifications,
      exchageRates: settings.exchageRates,
    );
  }

  factory SettingsModel.fromMap(
    Map<String, dynamic> map,
    List<ExchangeRate> exchangeRates,
  ) {
    return SettingsModel(
      defaultCurrency:
          CurrencyCode.values.byName(map['default_currency'] as String),
      enableNotifications: (map['enable_notifications'] as int) == 1,
      exchageRates: exchangeRates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'default_currency': defaultCurrency.name,
      'enable_notifications': enableNotifications ? 1 : 0,
    };
  }

  String toJson() => jsonEncode(toMap());

  @override
  String toString() {
    return 'SettingsModel(defaultCurrency: $defaultCurrency, enableNotifications: $enableNotifications, exchageRates: $exchageRates)';
  }
}
