import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../controllers/pos_providers.dart';
import '../controllers/quick_products_controller.dart';
import 'dialogs/manage_quick_products_dialog.dart';

class QuickProductsSection extends ConsumerWidget {
  const QuickProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickProducts = ref.watch(quickProductsProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const ManageQuickProductsDialog(),
              );
            },
            tooltip: 'تعديل المنتجات السريعة',
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withValues(alpha:0.1),
              foregroundColor: AppTheme.primaryColor,
            ),
            icon: const Icon(Icons.flash_on),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: quickProducts.isEmpty
                ? const Text(
                    'المنتجات السريعة فارغة، اضغط لإضافة منتجات',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: quickProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final product = quickProducts[index];
                      return ActionChip(
                        onPressed: () {
                          ref.read(posControllerProvider.notifier).addToCart(product);
                        },
                        label: Text(product.globalProduct.name),
                        backgroundColor: AppTheme.surfaceColor,
                        shadowColor: const Color(0x33000000),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        avatar: const Icon(Icons.add_shopping_cart, size: 16),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
