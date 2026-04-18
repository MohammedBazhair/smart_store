import 'package:flutter/material.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;

class ProductExpiryStatus {
  const ProductExpiryStatus({
    required this.color,
    required this.text,
    required this.icon,
  });

  factory ProductExpiryStatus.valid() {
    return const ProductExpiryStatus(
      color: AppTheme.validColor,
      text: 'صالح',
      icon: Icons.check_circle,
    );
  }

  factory ProductExpiryStatus.from(DateTime expiryDate) {
    final days = date_utils.DateTimeUtils.daysUntilExpiry(expiryDate);
    final text = date_utils.DateTimeUtils.timeUntilExpiry(expiryDate) ?? 'صالح';

    if (days == null) {
      return ProductExpiryStatus.valid();
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
        icon: Icons.warning_rounded,
      );
    } else if (days <= 30) {
      return ProductExpiryStatus(
        color: Colors.orange,
        text: text,
        icon: Icons.warning_rounded,
      );
    } else {
      return ProductExpiryStatus.valid(); // 🟢
    }
  }

  final Color color;
  final String text;
  final IconData icon;

  @override
  String toString() {
    return 'ProductExpiryStatus(color: $color, text: $text, icon: $icon)';
  }
}
