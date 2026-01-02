import 'package:equatable/equatable.dart';

import '../../../core/constants/enums.dart';

/// كيان الإعدادات
class Settings extends Equatable {

  const Settings({
    required this.id,
    required this.defaultCurrency,
    required this.exchangeRate,
    required this.alertDays30,
    required this.alertDays7,
    required this.alertDays1,
    required this.enableNotifications,
  });
  final String id;
  final Currency defaultCurrency;
  final double exchangeRate; // 1 SAR = ? YER
  final int alertDays30;
  final int alertDays7;
  final int alertDays1;
  final bool enableNotifications;

  @override
  List<Object?> get props => [
        id,
        defaultCurrency,
        exchangeRate,
        alertDays30,
        alertDays7,
        alertDays1,
        enableNotifications,
      ];

  /// نسخ الإعدادات مع تحديث بعض القيم
  Settings copyWith({
    String? id,
    Currency? defaultCurrency,
    double? exchangeRate,
    int? alertDays30,
    int? alertDays7,
    int? alertDays1,
    bool? enableNotifications,
  }) {
    return Settings(
      id: id ?? this.id,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      alertDays30: alertDays30 ?? this.alertDays30,
      alertDays7: alertDays7 ?? this.alertDays7,
      alertDays1: alertDays1 ?? this.alertDays1,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }
}

