import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../controllers/product_provider.dart';
import '../widgets/products_widgets/product_filter_dialog.dart';
import '../widgets/products_widgets/product_search_bar.dart';
import '../widgets/products_widgets/products_empty_state.dart';
import '../widgets/products_widgets/products_list.dart';
import 'upsert_product_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({
    super.key,
    required this.products,
    this.title,
  });

  final List<StoreProduct> products;
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
    final productsAsync = ref.watch(searchFilterProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'المنتجات'),
      ),
      body: Skeletonizer(
        enabled: query.hasQuery && productsAsync.isLoading,
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
                  child: !query.hasQuery
                      ? _buildProductsBody(widget.products, query)
                      : productsAsync.when(
                          data: (filteredProducts) {
                            return _buildProductsBody(filteredProducts, query);
                          },
                          loading: () {
                            final fakeProducts = StoreProduct.fakeProducts;

                            return Skeletonizer(
                              child: ProductsList(
                                products: fakeProducts,
                              ),
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
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushTo(const UpesertProductScreen()),
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
      ),
    );
  }

  Widget _buildProductsBody(List<StoreProduct> products, ProductQuery query) {
    if (products.isEmpty) {
      return ProductsEmptyState(text: query.uiNotFoundText);
    }
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(appSyncLoadingProvider.notifier).state = true;
        await ref.refresh(appSyncProvider.future);
        ref.read(appSyncLoadingProvider.notifier).state = false;
        await ref.read(productControllerProvider.notifier).loadStoreProducts();
      },
      child: ProductsList(
        products: products,
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
