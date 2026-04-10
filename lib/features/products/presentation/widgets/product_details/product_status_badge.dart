import 'package:flutter/material.dart';

import '../../../domain/entities/product_expiry_status.dart';
import '../../../domain/entities/store_product.dart';

class ProductStatusBadge extends StatelessWidget {
  const ProductStatusBadge({
    super.key,
    required this.product,
  });

  final StoreProduct product;
  @override
  Widget build(BuildContext context) {
    final status =
        ProductExpiryStatus.from(product.expiryDate ?? DateTime(9999999));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: status.color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
