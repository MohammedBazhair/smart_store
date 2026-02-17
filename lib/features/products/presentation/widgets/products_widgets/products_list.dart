import 'package:flutter/material.dart';

import '../../../domain/entities/seller_product.dart';
import '../product_card/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({
    super.key,
    required this.products,
    required this.onRefresh,
  });

  final List<SellerProduct> products;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return AnimatedProductCard(
            product: products[index],
          );
        },
      ),
    );
  }
}
