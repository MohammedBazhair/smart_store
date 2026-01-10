import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';

/// كيان الإعدادات
class Settings extends Equatable {
  const Settings({
    required this.defaultCurrency,
    required this.exchangeRate,
    required this.enableNotifications,
  });

  factory Settings.theDefault() {
    return const Settings(
      defaultCurrency: AppConstants.defaultCurrency,
      exchangeRate: AppConstants.defaultExchangeRate,
      enableNotifications: true,
    );
  }
  final Currency defaultCurrency;
  final double exchangeRate; // 1 SAR = ? YER

  final bool enableNotifications;

  @override
  List<Object?> get props => [
        defaultCurrency,
        exchangeRate,
        enableNotifications,
      ];

  /// نسخ الإعدادات مع تحديث بعض القيم
  Settings copyWith({
    Currency? defaultCurrency,
    double? exchangeRate,
    bool? enableNotifications,
  }) {
    return Settings(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }
}
