import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../domain/product.dart';
import '../../controllers/product_provider.dart';
import '../product_card/product_card.dart';

class ProductsList extends ConsumerWidget {
  const ProductsList({
    super.key,
    required this.products,
    this.isLoading = false,
  });
  final List<Product> products;
  final bool isLoading;

  @override
  Widget build(BuildContext context, ref) {
    return Skeletonizer(
      enabled: isLoading,
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(productsProvider),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return AnimatedProductCard(
              product: product,
            );
          },
        ),
      ),
    );
  }
}
