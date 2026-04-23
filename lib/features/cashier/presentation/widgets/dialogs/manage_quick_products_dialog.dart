import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../audio/presentation/controller/audio_provider.dart';
import '../../../../products/domain/entities/store_product.dart';
import '../../../../products/presentation/widgets/product_card/product_card.dart';
import '../../controllers/pos_providers.dart';
import '../../controllers/quick_products_state.dart';

Future<void> showManageQuickProductsDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const ManageQuickProductsDialog(),
  );
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

            const _TabsQuick(),

            Expanded(
              child: ref.watch(quickProductsControllerProvider).when(
                    data: (state) => _ProductsBody(state.displayedProducts),
                    loading: () {
                      final fakeProducts = StoreProduct.fakeProducts;

                      return Skeletonizer(
                        child: _ProductsBody(fakeProducts),
                      );
                    },
                    error: (error, stack) => Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل المنتجات',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
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
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        final isQuick = ref.watch(
          quickProductsControllerProvider.select(
            (s) => s.value?.quickProducts.containsKey(product.id) ?? false,
          ),
        );
        return GestureDetector(
          onLongPress: () {
            ref
                .read(quickProductsControllerProvider.notifier)
                .toggleProduct(product);
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
    final selectedType = ref.watch(
      quickProductsControllerProvider
          .select((s) => s.value?.selectedTab ?? QuickTabType.onlyQuick),
    );

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
              ref.read(quickProductsControllerProvider.notifier).changeTab(t);
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
