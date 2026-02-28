import 'package:flutter/material.dart';

import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../domain/entities/store_product.dart';

class ProductMetaColumn extends StatelessWidget {
  const ProductMetaColumn(this.product, {super.key});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.quantity != null)
          Row(
            spacing: 4,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              Text(
                'الكمية: ${product.quantityText}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        if (product.expiryDate != null)
          Row(
            spacing: 4,
            children: [
              const Icon(
                Icons.calendar_month,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              Text(
                date_utils.DateTimeUtils.formatDate(product.expiryDate!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
