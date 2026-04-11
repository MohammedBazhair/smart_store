import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../products/presentation/controllers/product_provider.dart';
import '../../controllers/quick_products_controller.dart';

class ManageQuickProductsDialog extends ConsumerStatefulWidget {
  const ManageQuickProductsDialog({super.key});

  @override
  ConsumerState<ManageQuickProductsDialog> createState() =>
      _ManageQuickProductsDialogState();
}

class _ManageQuickProductsDialogState
    extends ConsumerState<ManageQuickProductsDialog> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allProducts =
        ref.watch(productControllerProvider).products.values.toList();
    final quickProducts = ref.watch(quickProductsProvider);

    final filteredProducts = allProducts.where((p) {
      if (searchQuery.isEmpty) return true;
      return p.globalProduct.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          'إدارة المنتجات السريعة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن منتج...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isQuick =
                        quickProducts.any((q) => q.id == product.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isQuick
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          ref
                              .read(quickProductsProvider.notifier)
                              .toggleProduct(product);
                        },
                        title: Text(product.globalProduct.name),
                        subtitle: Text(
                          product.globalProduct.barcode ?? 'بدون باركود',
                        ),
                        trailing: Icon(
                          isQuick ? Icons.star : Icons.star_border,
                          color: isQuick ? Colors.amber : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
