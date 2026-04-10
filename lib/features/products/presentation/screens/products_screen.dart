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

extension ProductListSort on List<StoreProduct> {
  List<StoreProduct> sortProducts(ProductSortType sortType) {
    if (sortType == ProductSortType.none) return this;
    final list = toList();
    list.sort((a, b) {
      switch (sortType) {
        case ProductSortType.quantityAsc:
          return (a.quantity ?? 0).compareTo(b.quantity ?? 0);
        case ProductSortType.quantityDesc:
          return (b.quantity ?? 0).compareTo(a.quantity ?? 0);
        case ProductSortType.expiryAsc:
          final dateA = a.expiryDate ?? DateTime(2100);
          final dateB = b.expiryDate ?? DateTime(2100);
          return dateA.compareTo(dateB);
        case ProductSortType.expiryDesc:
          final dateA = a.expiryDate ?? DateTime(1900);
          final dateB = b.expiryDate ?? DateTime(1900);
          return dateB.compareTo(dateA);
        case ProductSortType.none:
          return 0;
      }
    });
    return list;
  }
}


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

    final state = ref.watch(productControllerProvider);
    final List<StoreProduct> products = switch (widget.listType) {
      ProductListType.all => state.products.values.toList(),
      ProductListType.expired => state.expiredProducts,
      ProductListType.nearExpiry => state.nearbyExpiredProducts,
    };

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

                const SizedBox(height: 12),

                // 🔀 رقاقات الترتيب (Premium UX)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ProductSortType.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final type = ProductSortType.values[index];
                      final isSelected = query.sortType == type;

                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (type != ProductSortType.none) ...[
                              Icon(
                                type.icon,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(type.label),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          final newType =
                              selected ? type : ProductSortType.none;
                          ref.read(productQueryProvider.notifier).update(
                                (q) => q.copyWith(sortType: newType),
                              );
                          // We don't need to trigger a full repo search if we just want to sort locally,
                          // but to be safe and consistent with query matching, we can call search:
                          if (query.isSearching || query.hasCategory) {
                             ref.read(productSearchProvider.notifier).search();
                          }
                        },
                        showCheckmark: false,
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

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
    final sortedProducts = products.sortProducts(query.sortType);

    if (sortedProducts.isEmpty) {
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
        products: sortedProducts,
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
