import 'package:flutter/material.dart';
import '../../../domain/entities/seller_product.dart';
import 'product_status_badge.dart';

class ProductHeaderInfo extends StatelessWidget {
  const ProductHeaderInfo({super.key, required this.product});
  final SellerProduct product;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 24),
        ProductStatusBadge(
          product: product,
        ),
      ],
    );
  }
}
