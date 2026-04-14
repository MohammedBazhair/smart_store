import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../controllers/product_provider.dart';
import '../widgets/product_card/product_card.dart';
import '../widgets/products_widgets/product_search_bar.dart';
import '../widgets/products_widgets/products_empty_state.dart';
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

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({
    super.key,
    this.listType = ProductListType.all,
    this.title,
  });

  final ProductListType listType;
  final String? title;

  @override
  Widget build(BuildContext context, ref) {
    final query = ref.watch(productQueryProvider);
    final productsSearchAsync = ref.watch(productSearchProvider);

    final state = ref.watch(productControllerProvider);
    final List<StoreProduct> products = switch (listType) {
      ProductListType.all => state.products.values.toList(),
      ProductListType.expired => state.expiredProducts,
      ProductListType.nearExpiry => state.nearbyExpiredProducts,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'المنتجات'),
      ),
      body: Skeletonizer(
        enabled: query.hasQuery && productsSearchAsync.isLoading,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                const ProductSearchBar(),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
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
                          spacing: 5,
                          children: [
                            if (type != ProductSortType.none)
                              Icon(
                                type.icon,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                              ),
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
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: !query.hasQuery
                      ? _ProductsBody(products)
                      : productsSearchAsync.when(
                          data: (filteredProducts) {
                            return _ProductsBody(filteredProducts);
                          },
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
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushTo(const UpsertProductScreen()),
        child: const Icon(Icons.add_circle),
      ),
    );
  }
}

class _ProductsBody extends ConsumerWidget {
  const _ProductsBody(this.products);
  final List<StoreProduct> products;

  Future<void> onRefresh(WidgetRef ref) async {
    final container = ref.container;
    container.read(appSyncLoadingProvider.notifier).state = true;
    try {
      await container.refresh(appSyncProvider.future);
    } finally {
      container.read(appSyncLoadingProvider.notifier).state = false;
    }

    await container
        .read(productControllerProvider.notifier)
        .loadStoreProducts();
  }

  @override
  Widget build(BuildContext context, ref) {
    final query = ref.watch(productQueryProvider);
    final sortedProducts = products.sortProducts(query.sortType);

    if (sortedProducts.isEmpty) {
      return ProductsEmptyState(text: query.uiNotFoundText);
    }
    return RefreshIndicator(
      onRefresh: () => onRefresh(ref),
      child: ListView.builder(
        itemCount: sortedProducts.length,
        itemBuilder: (context, index) => ProductCard(product: products[index]),
      ),
    );
  }
}
