import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/store_product.dart';
import '../controllers/product_provider.dart';
import '../widgets/product_details/product_header_card.dart';
import '../widgets/product_details/product_info_section.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(currentProductProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
      ),
      body: productAsync.when(
        data: (product) => ProductDetailsBody(product: product),
        loading: () => Skeletonizer(
          child: ProductDetailsBody(product: StoreProduct.fake()),
        ),
        error: (_, __) => const Center(
          child: Text('حدث خطأ أثناء عرض المنتج'),
        ),
      ),
    );
  }
}

class ProductDetailsBody extends ConsumerWidget {
  const ProductDetailsBody({super.key, required this.product});
  final StoreProduct? product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (product == null) {
      return const Center(
        child: Text('غير موجود'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final productId = product?.globalProduct.id;
        if (productId == null) return;
        await ref.refresh(productByIdProvider(productId).future);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        children: [
          ProductHeaderInfo(product: product!),
          const SizedBox(height: 10),
          ProductInfoSection(product: product!),
        ],
      ),
    );
  }
}
