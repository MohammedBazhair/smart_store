import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/shared/providers/core_providers.dart';
import '../../../domain/entities/store_product.dart';
import '../../controllers/product_provider.dart';
import '../product_card/product_card.dart';
import 'product_search_bar.dart';
import 'products_empty_state.dart';
import 'products_tabs.dart';

final _pageStorageBucketProvider = Provider((ref) => PageStorageBucket());

class ProductsView extends ConsumerWidget {
  const ProductsView({
    super.key,
    this.isPreviewMode = false,
  });

  final bool isPreviewMode;

  @override
  Widget build(BuildContext context, ref) {
    return PageStorage(
      bucket: ref.read(_pageStorageBucketProvider),
      child: isPreviewMode
          ? const ProductsPreviewList()
          : const ProductsFullView(),
    );
  }
}

class ProductsPreviewList extends ConsumerWidget {
  const ProductsPreviewList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(homePreviewProductsProvider);

    return ProductsList(products: products);
  }
}

class ProductsFullView extends ConsumerWidget {
  const ProductsFullView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(productSearchControllerProvider);

    return Column(
      children: [
        const ProductSearchBar(),
        const SizedBox(height: 12),
        const ProductsTabs(),
        const SizedBox(height: 12),
        Expanded(
          child: filteredProductsAsync.when(
            data: (products) => ProductsList(products: products),
            loading: () => ProductsList(
              products: StoreProduct.fakeProducts,
              isLoading: true,
            ),
            error: (_, __) => const Center(
              child: Text('حدث خطأ أثناء تحميل المنتجات'),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductsList extends ConsumerWidget {
  const ProductsList({
    super.key,
    required this.products,
    this.isLoading = false,
  });

  final List<StoreProduct> products;
  final bool isLoading;

  Future<void> _onRefresh(WidgetRef ref) async {
    await ref.read(appSyncControllerProvider.notifier).sync(isManual: true);

    await ref.read(productControllerProvider.notifier).loadStoreProducts();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(productQueryProvider);

    if (products.isEmpty) {
      return ProductsEmptyState(text: query.uiNotFoundText);
    }

    return Skeletonizer(
      enabled: isLoading,
      child: RefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: ListView.separated(
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(key: ValueKey(product.id), product: product);
          },
        ),
      ),
    );
  }
}
