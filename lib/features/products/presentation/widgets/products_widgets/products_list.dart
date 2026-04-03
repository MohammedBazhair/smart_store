import 'package:flutter/material.dart';

import '../../../domain/entities/store_product.dart';
import '../product_card/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({
    super.key,
    required this.products,
  });

  final List<StoreProduct> products;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
        );
      },
    );
  }
}
