import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../controllers/pos_providers.dart';
import 'dialogs/manage_quick_products_dialog.dart';

class QuickProductsSection extends ConsumerWidget {
  const QuickProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickProducts = ref.watch(quickProductsProvider);

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
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final product = quickProducts.values.elementAt(index);

                return ActionChip(
                  onPressed: () {
                    ref.read(posControllerProvider.notifier).addToCart(product);
                  },
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
            ),
          ),
        ],
      ),
    );
  }
}
