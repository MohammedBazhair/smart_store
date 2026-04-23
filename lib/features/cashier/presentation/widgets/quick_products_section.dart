import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../products/domain/entities/store_product.dart';
import '../controllers/pos_providers.dart';
import 'dialogs/manage_quick_products_dialog.dart';

class QuickProductsSection extends ConsumerWidget {
  const QuickProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickProductsAsync = ref.watch(quickProductsControllerProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      color: AppTheme.primaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: () => showManageQuickProductsDialog(context),
            tooltip: 'تعديل المنتجات السريعة',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.flash_on),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: quickProductsAsync.when(
              data: (state) => QuickProductsBody(
                quickProducts: state.quickProductsList,
                addToCart: ref.read(posControllerProvider.notifier).addToCart,
              ),
              loading: () => Skeletonizer(
                child:
                    QuickProductsBody(quickProducts: StoreProduct.fakeProducts),
              ),
              error: (error, stackTrace) =>
                  const QuickProductsBody(quickProducts: []),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickProductsBody extends StatelessWidget {
  const QuickProductsBody({
    super.key,
    required this.quickProducts,
    this.addToCart,
  });
  final List<StoreProduct> quickProducts;
  final void Function(StoreProduct)? addToCart;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: quickProducts.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final product = quickProducts[index];

        return ActionChip(
          onPressed: () => addToCart?.call(product),
          label: Text(
            product.globalProduct.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          backgroundColor: AppTheme.surfaceColor,
          shadowColor: const Color.fromARGB(146, 209, 209, 209),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(
              color: Colors.transparent,
            ),
          ),
        );
      },
    );
  }
}
