import '../../../core/constants/enums.dart';
import '../domain/settings.dart';

/// نموذج الإعدادات للتعامل مع قاعدة البيانات
class SettingsModel extends Settings {
  const SettingsModel({
    required super.id,
    required super.defaultCurrency,
    required super.exchangeRate,
    required super.alertDays30,
    required super.alertDays7,
    required super.alertDays1,
    required super.enableNotifications,
  });

  /// تحويل من Entity إلى Model
  factory SettingsModel.fromEntity(Settings settings) {
    return SettingsModel(
      id: settings.id,
      defaultCurrency: settings.defaultCurrency,
      exchangeRate: settings.exchangeRate,
      alertDays30: settings.alertDays30,
      alertDays7: settings.alertDays7,
      alertDays1: settings.alertDays1,
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
      alertDays30: map['alert_days_30'] as int,
      alertDays7: map['alert_days_7'] as int,
      alertDays1: map['alert_days_1'] as int,
      enableNotifications: (map['enable_notifications'] as int) == 1,
    );
  }

  /// تحويل من SettingsModel إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'default_currency': defaultCurrency.name,
      'exchange_rate': exchangeRate,
      'alert_days_30': alertDays30,
      'alert_days_7': alertDays7,
      'alert_days_1': alertDays1,
      'enable_notifications': enableNotifications ? 1 : 0,
    };
  }
}
