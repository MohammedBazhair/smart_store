import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/products/domain/entities/store_product.dart';
import '../../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../../features/products/presentation/screens/product_details_screen.dart';
import '../../../../../features/products/presentation/screens/products_screen.dart';
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
                  ProductsScreen(
                    products: nearExpiryProducts,
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
        return ListTile(
          leading: const Icon(
            Icons.warning,
            color: AppTheme.nearExpiryColor,
          ),
          title: Text(product.globalProduct.name),
          subtitle: product.expiryDate == null
              ? null
              : Text(
                  'ينتهي في ${DateTime.now().difference(product.expiryDate!).inDays.abs()} أيام',
                ),
          trailing: const Icon(Icons.chevron_left),
          onTap: () {
            context.pushTo(
              ProductDetailsScreen(
                productId: product.globalProduct.id!,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
