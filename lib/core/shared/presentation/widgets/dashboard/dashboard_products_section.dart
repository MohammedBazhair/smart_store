import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/products/domain/entities/product_query.dart';
import '../../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../../features/products/presentation/screens/products_screen.dart';
import '../../../../extensions/extensions.dart';

class DashboardProductsSection extends ConsumerWidget {
  const DashboardProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المنتجات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                ref.read(productQueryProvider.notifier).update(
                      (s) => s.copyWith(
                        statusType:
                            ProductExpirationStatus.nearbyExpiredProducts,
                      ),
                    );
                context.pushTo(
                  const ProductsScreen(
                    title: 'المنتجات',
                  ),
                );
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const SizedBox(
          height: 300,
          child: ProductsBody(showSimpleCount: true),
        ),
      ],
    );
  }
}
