import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../../features/products/presentation/screens/product_details_screen.dart';
import '../../../../../features/products/presentation/screens/products_screen.dart';
import '../../../../extensions/extensions.dart';
import '../../theme/app_theme.dart';
import '../common/error_widget.dart';
import '../common/loading_widget.dart';

class DashboardNearExpirySection extends ConsumerWidget {
  const DashboardNearExpirySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearExpiryAsync = ref.watch(nearExpiryProductsProvider);

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
                    productsProvider: nearExpiryProductsProvider,
                    title: 'المنتجات قريبة الانتهاء',
                  ),
                );
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        nearExpiryAsync.when(
          data: (products) {
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
                        productId: product.id!,
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorDisplayWidget(message: e.toString()),
        ),
      ],
    );
  }
}
