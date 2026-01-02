import 'package:flutter/material.dart';

import '../../../../../shared/presentation/theme/app_theme.dart';
import '../../../domain/product.dart';

class ProductMetaRow extends StatelessWidget {
  const ProductMetaRow(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.inventory_2, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          'الكمية: ${product.quantity}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        const Icon(Icons.category, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          product.category.label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
