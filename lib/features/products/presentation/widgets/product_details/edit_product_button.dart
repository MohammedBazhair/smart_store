import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../domain/product.dart';
import '../../controllers/product_controller.dart';
import '../../screens/add_product_screen.dart';

class EditProductButton extends ConsumerWidget {
  const EditProductButton({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      icon: const Icon(Icons.edit),
      label: const Text('تعديل المنتج'),
      onPressed: () async {
        final updated = await context.pushTo<Product?>(
          AddProductScreen(product: product),
        );
        if (updated == null) return;

        await ref
            .read(productControllerProvider.notifier)
            .updateProduct(oldProduct: product, newProduct: updated);
      },
    );
  }
}
