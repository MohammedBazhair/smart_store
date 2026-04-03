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

enum ProductListType { all, expired, nearExpiry }

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({
    super.key,
    this.listType = ProductListType.all,
    this.title,
  });

  final ProductListType listType;
  final String? title;

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(productQueryProvider);
    final productsSearchAsync = ref.watch(productSearchProvider);

    final List<StoreProduct> products = ref.watch(
      productControllerProvider.select(
        (s) => switch (widget.listType) {
          ProductListType.all => s.products.values.toList(),
          ProductListType.expired => s.expiredProducts,
          ProductListType.nearExpiry => s.nearbyExpiredProducts,
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'المنتجات'),
      ),
      body: Skeletonizer(
        enabled: query.hasQuery && productsSearchAsync.isLoading,
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
                          ref
                              .read(productQueryProvider.notifier)
                              .update((q) => q.copyWith(search: value.trim()));
                          ref.read(productSearchProvider.notifier).search();
                        },
                        onClear: () {
                          _searchController.clear();
                          ref
                              .read(productQueryProvider.notifier)
                              .update((q) => q.copyWith(search: ''));
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: query.hasCategory
                          ? query.category?.name
                          : 'فلترة المنتجات',
                      icon: query.hasCategory
                          ? const Icon(Icons.filter_list)
                          : const Icon(Icons.filter_list_off_rounded),
                      onPressed: () {
                        if (query.hasCategory) {
                          ref.read(productQueryProvider.notifier).update(
                                (q) => q.copyWith(clearCategory: true),
                              );
                        }
                        _showFilterDialog(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: !query.hasQuery
                      ? _buildProductsBody(products, query)
                      : productsSearchAsync.when(
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
        onPressed: () => context.pushTo(const UpsertProductScreen()),
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
        final container = ref.container;
        container.read(appSyncLoadingProvider.notifier).state = true;
        try {
          await container.refresh(appSyncProvider.future);
        } finally {
          container.read(appSyncLoadingProvider.notifier).state = false;
        }
        if (!mounted) return;
        await container
            .read(productControllerProvider.notifier)
            .loadStoreProducts();
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
          ref.read(productSearchProvider.notifier).search();
        },
      ),
    );
  }
}
