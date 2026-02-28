import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/store_product.dart';
import '../controllers/product_provider.dart';
import '../widgets/products_widgets/product_filter_dialog.dart';
import '../widgets/products_widgets/product_search_bar.dart';
import '../widgets/products_widgets/products_empty_state.dart';
import '../widgets/products_widgets/products_list.dart';
import 'add_product_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({
    super.key,
    required this.productsProvider,
    this.title,
  });

  final FutureProvider<List<StoreProduct>> productsProvider;
  final String? title;

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(productQueryProvider);

    final productsAsync = query.hasQuery
        ? ref.watch(searchFilterProductsProvider)
        : ref.watch(widget.productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'المنتجات'),
      ),
      body: Skeletonizer(
        enabled: productsAsync.isLoading,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // 🔍 شريط البحث
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: ProductSearchBar(
                        controller: _searchController,
                        query: query,
                        onChanged: (value) {
                          _debounceTimer?.cancel();
                          _debounceTimer =
                              Timer(const Duration(milliseconds: 800), () {
                            ref.read(productQueryProvider.notifier).update(
                                  (q) => q.copyWith(search: value.trim()),
                                );
                          });
                        },
                        onClear: () {
                          _searchController.clear();
                          _debounceTimer?.cancel();
                          ref
                              .read(productQueryProvider.notifier)
                              .update((q) => q.copyWith(search: ''));
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'فلترة المنتجات',
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: productsAsync.when(
                    loading: () {
                      final fakeProducts = StoreProduct.fakeProducts;

                      return ProductsList(
                        products: fakeProducts,
                        onRefresh: () async {
                          ref.invalidate(productsProvider);
                          ref.invalidate(searchFilterProductsProvider);
                        },
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
                    data: (products) {
                      if (products.isEmpty) {
                        return ProductsEmptyState(text: query.uiNotFoundText);
                      }
                      return ProductsList(
                        products: products,
                        onRefresh: () async {
                          ref.invalidate(productsProvider);
                          ref.invalidate(searchFilterProductsProvider);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushTo(const AddProductScreen()),
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ProductFilterDialog(
        initialCategory: ref.watch(productQueryProvider).category,
        onApply: (category) {
          ref.read(productQueryProvider.notifier).update(
                (q) => q.copyWith(category: category),
              );
        },
      ),
    );
  }
}
