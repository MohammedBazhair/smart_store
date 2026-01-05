import 'package:flutter/material.dart';

import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../../shared/presentation/theme/app_theme.dart';
import '../../../domain/product.dart';

class ProductStatusBadge extends StatelessWidget {
  const ProductStatusBadge({
    super.key,
    required this.product,
  });

  final Product product;
  @override
  Widget build(BuildContext context) {
    final remainingDays =
        date_utils.DateTimeUtils.daysUntilExpiry(product.expiryDate);
    final isExpired =
        date_utils.DateTimeUtils.isExpired(product.expiryDate) ?? false;
    final color = isExpired
        ? AppTheme.expiredColor
        : remainingDays != null && remainingDays <= 7
            ? AppTheme.nearExpiryColor
            : AppTheme.validColor;

    final text = isExpired
        ? 'منتهي'
        : remainingDays != null && remainingDays <= 30
            ? 'قريب الانتهاء'
            : 'صالح';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
