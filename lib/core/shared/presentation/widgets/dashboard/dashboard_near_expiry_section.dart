import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/products/domain/entities/store_product.dart';
import '../../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../../features/products/presentation/screens/products_screen.dart';
import '../../../../../features/products/presentation/widgets/product_card/product_card.dart';
import '../../../../extensions/extensions.dart';
import '../../theme/app_theme.dart';

class DashboardNearExpirySection extends ConsumerWidget {
  const DashboardNearExpirySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearExpiryProducts = ref.watch(
      productControllerProvider.select((s) => s.nearbyExpiredProducts),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قريبة من الانتهاء',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                context.pushTo(
                  const ProductsScreen(
                    listType: ProductListType.nearExpiry,
                    title: 'المنتجات قريبة الانتهاء',
                  ),
                );
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _NearbySectionBody(products: nearExpiryProducts),
      ],
    );
  }
}

class _NearbySectionBody extends StatelessWidget {
  const _NearbySectionBody({required this.products});
  final List<StoreProduct> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'لا توجد منتجات قريبة من الانتهاء',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: products.take(3).map((product) {
        return ProductCard(product: product);
      }).toList(),
    );
  }
}
