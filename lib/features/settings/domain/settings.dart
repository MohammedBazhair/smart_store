import 'package:equatable/equatable.dart';

import '../../../core/constants/enums.dart';

/// كيان الإعدادات
class Settings extends Equatable {
  const Settings({
    required this.id,
    required this.defaultCurrency,
    required this.exchangeRate,
    required this.enableNotifications,
  });

  factory Settings.fake() {
    return const Settings(
      id: '3',
      defaultCurrency: Currency.YER,
      exchangeRate: 300,
      enableNotifications: true,
    );
  }
  final String id;
  final Currency defaultCurrency;
  final double exchangeRate; // 1 SAR = ? YER
 
  final bool enableNotifications;

  @override
  List<Object?> get props => [
        id,
        defaultCurrency,
        exchangeRate,
        enableNotifications,
      ];

  /// نسخ الإعدادات مع تحديث بعض القيم
  Settings copyWith({
    String? id,
    Currency? defaultCurrency,
    double? exchangeRate,
    bool? enableNotifications,
  }) {
    return Settings(
      id: id ?? this.id,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }
}
