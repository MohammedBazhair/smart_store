import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../shared/presentation/theme/app_theme.dart';

class ProductExpiryStatus {
  const ProductExpiryStatus({
    required this.color,
    required this.text,
    required this.icon,
  });

  factory ProductExpiryStatus.from(DateTime expiryDate) {
    final days = date_utils.DateUtils.daysUntilExpiry(expiryDate);

    if (days < 0) {
      return const ProductExpiryStatus(
        color: AppTheme.expiredColor,
        text: 'منتهي',
        icon: Icons.cancel,
      );
    } else if (days <= 7) {
      return const ProductExpiryStatus(
        color: AppTheme.nearExpiryColor,
        text: 'قريب الانتهاء',
        icon: Icons.warning,
      );
    } else if (days <= 29) {
      return ProductExpiryStatus(
        color: AppTheme.validColor,
        text: '$days أيام متبقية',
        icon: Icons.check_circle,
      );
    } else if (days ~/ 30 >= 12) {
      final months = days ~/ 30;
      final years = months ~/ 12;

      return ProductExpiryStatus(
        color: AppTheme.validColor,
        text: years == 1 ? 'سنة متبقية' : '$years سنوات متبقية',
        icon: Icons.check_circle,
      );
    } else {
      final months = days ~/ 30;

      return ProductExpiryStatus(
        color: AppTheme.validColor,
        text: months == 1
            ? 'شهر متبقي'
            : months == 2
                ? 'شهرين متبقيين'
                : '$months أشهر متبقية',
        icon: Icons.check_circle,
      );
    }
  }
  final Color color;
  final String text;
  final IconData icon;
}
