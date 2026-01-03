import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../shared/presentation/widgets/common/loading_widget.dart';
import '../../domain/product.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_details/delete_product_dialog.dart';
import '../widgets/product_details/product_header_card.dart';
import '../widgets/product_details/product_info_section.dart';

final currentProductProvider = StateProvider<Product?>((ref) => null);

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});
  final int productId;

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
    
    return productAsync.when(
      data: (product) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل المنتج'),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.red.shade300,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    if (product == null) {
                      return context.showSnakbar('لايمكن حذف منتج غير موجود');
                    }
                    showDialog(
                      context: context,
                      builder: (_) => DeleteProductDialog(product: product),
                    );
                  },
                ),
              ),
            ],
          ),
          body: ProductDetailsBody(product: product),
        );
      },
      loading: LoadingWidget.new,
      error: (_, __) => const Center(
        child: Text('حدث خطأ أثناء عرض المنتج'),
      ),
    );
  }
}

class ProductDetailsBody extends ConsumerWidget {
  const ProductDetailsBody({super.key, required this.product});
  final Product? product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (product == null) {
      return const Center(
        child: Text('غير موجود'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProductHeaderInfo(product: product!),
        const SizedBox(height: 10),
        ProductInfoSection(product: product!),
      ],
    );
  }
}
