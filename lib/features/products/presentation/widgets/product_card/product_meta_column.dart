import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../domain/entities/store_product.dart';

class ProductMetaColumn extends ConsumerWidget {
  const ProductMetaColumn(this.product, {super.key});

  final StoreProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
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
                product.expiryDate!.formattedDate,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
