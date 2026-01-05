import '../../../core/constants/enums.dart';
import '../domain/settings.dart';

/// نموذج الإعدادات للتعامل مع قاعدة البيانات
class SettingsModel extends Settings {
  const SettingsModel({
    required super.id,
    required super.defaultCurrency,
    required super.exchangeRate,
    required super.enableNotifications,
  });

  /// تحويل من Entity إلى Model
  factory SettingsModel.fromEntity(Settings settings) {
    return SettingsModel(
      id: settings.id,
      defaultCurrency: settings.defaultCurrency,
      exchangeRate: settings.exchangeRate,
      enableNotifications: settings.enableNotifications,
    );
  }

  /// تحويل من Map إلى SettingsModel
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'] as String,
      defaultCurrency:
          Currency.values.byName(map['default_currency'] as String),
      exchangeRate: (map['exchange_rate'] as num).toDouble(),
      enableNotifications: (map['enable_notifications'] as int) == 1,
    );
  }

  /// تحويل من SettingsModel إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'default_currency': defaultCurrency.name,
      'exchange_rate': exchangeRate,
      'enable_notifications': enableNotifications ? 1 : 0,
    };
  }
}
