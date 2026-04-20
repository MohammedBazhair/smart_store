import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../audio/presentation/controller/audio_provider.dart';
import '../../../../products/domain/entities/store_product.dart';
import '../../../../products/presentation/controllers/product_provider.dart';
import '../../../../products/presentation/widgets/product_card/product_card.dart';
import '../../../../products/presentation/widgets/products_widgets/product_search_bar.dart';
import '../../controllers/pos_providers.dart';

Future<void> showManageQuickProductsDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const ManageQuickProductsDialog(),
  );
}

enum QuickTabType {
  onlyQuick('المنتجات السريعة'),
  withoutBarcode('بلا باركود');

  const QuickTabType(this.label);
  final String label;
}

class ManageQuickProductsDialog extends ConsumerWidget {
  const ManageQuickProductsDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 12,
        ),
        child: Column(
          spacing: 24,
          children: [
            // Header
            const Text(
              'إدارة المنتجات السريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const ProductSearchBar(),

            const _TabsQuick(),

            Expanded(
              child: ref.watch(productSearchProvider).when(
                        data: _ProductsBody.new,
                        loading: () {
                          final fakeProducts = StoreProduct.fakeProducts;

                          return Skeletonizer(
                            child: _ProductsBody(fakeProducts),
                          );
                        },
                        error: (error, stack) {
                          return Center(
                            child: Text(
                              'حدث خطأ أثناء تحميل المنتجات',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        },
                      ),
            ),
            // List
          ],
        ),
      ),
    );
  }
}

class _ProductsBody extends ConsumerWidget {
  const _ProductsBody(
    this.products,
  );

  final List<StoreProduct> products;

  @override
  Widget build(BuildContext context, ref) {
    final quickProducts = ref.watch(quickProductsProvider);

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isQuick = quickProducts.containsKey(product.id);

        return GestureDetector(
          onLongPress: () {
            ref.read(quickProductsProvider.notifier).toggleProduct(product);
            ref.read(audioControllerProvider.notifier).playClick();
          },
          child: ProductCard(
            product: product,
            isSelected: isQuick,
            onTap: () {
              ref.read(posControllerProvider.notifier).addToCart(product);
            },
          ),
        );
      },
    );
  }
}

class _TabsQuick extends ConsumerWidget {
  const _TabsQuick();

  @override
  Widget build(BuildContext context, ref) {
    final selectedType = ref.watch(quickTabProvider);

    return Row(
      spacing: 12,
      children: QuickTabType.values.map(
        (t) {
          final isSelected = t == selectedType;
          return ChoiceChip(
            label: Text(t.label),
            selected: isSelected,
            onSelected: (newValue) {
              if (!newValue || isSelected) return;
              ref.read(quickTabProvider.notifier).state = t;
            },
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          );
        },
      ).toList(),
    );
  }
}
