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
    final text = date_utils.DateUtils.timeUntilExpiry(expiryDate) ?? 'صالح';
    if (days == null) {
      return ProductExpiryStatus(
        color: AppTheme.validColor,
        text: text,
        icon: Icons.check_circle,
      );
    }

    if (days < 0) {
      return ProductExpiryStatus(
        color: AppTheme.expiredColor,
        text: text,
        icon: Icons.cancel,
      );
    } else if (days <= 7) {
      return ProductExpiryStatus(
        color: AppTheme.nearExpiryColor,
        text: text,
        icon: Icons.warning,
      );
    } else if (days <= 29) {
      return ProductExpiryStatus(
        color: AppTheme.validColor,
        text: text,
        icon: Icons.check_circle,
      );
    } else if (days ~/ 30 >= 12) {
      return ProductExpiryStatus(
        color: AppTheme.validColor,
        text: text,
        icon: Icons.check_circle,
      );
    } else {
      return ProductExpiryStatus(
        color: AppTheme.validColor,
        text: text,
        icon: Icons.check_circle,
      );
    }
  }
  final Color color;
  final String text;
  final IconData icon;
}
