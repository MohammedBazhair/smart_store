import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/seller_product.dart';
import '../controllers/product_controller.dart';
import '../controllers/product_provider.dart';
import '../widgets/product_details/delete_product_dialog.dart';
import '../widgets/product_details/product_header_card.dart';
import '../widgets/product_details/product_info_section.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    ref.listen(
      productByIdProvider(productId),
      (previous, next) {
        next.whenData((product) {
          ref.read(currentProductProvider.notifier).state = product;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            tooltip: 'حذف المنتج',
            icon: const Icon(
              Icons.delete_outline,
            ),
            onPressed: () {
              final product = ref.read(currentProductProvider);
              if (product == null) {
                return context.showSnakbar(
                  'لايمكن حذف منتج غير موجود',
                  type: SnackBarType.error,
                );
              }
              showDialog(
                context: context,
                builder: (_) => DeleteProductDialog(product: product),
              );
            },
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) => ProductDetailsBody(product: product),
        loading: () => Skeletonizer(
            child: ProductDetailsBody(product: SellerProduct.fake())),
        error: (_, __) => const Center(
          child: Text('حدث خطأ أثناء عرض المنتج'),
        ),
      ),
    );
  }
}

class ProductDetailsBody extends ConsumerWidget {
  const ProductDetailsBody({super.key, required this.product});
  final SellerProduct? product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (product == null) {
      return const Center(
        child: Text('غير موجود'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      children: [
        ProductHeaderInfo(product: product!),
        const SizedBox(height: 10),
        ProductInfoSection(product: product!),
      ],
    );
  }
}
