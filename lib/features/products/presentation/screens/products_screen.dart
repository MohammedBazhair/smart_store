import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../domain/entities/store_product.dart';
import '../controllers/product_provider.dart';
import '../widgets/product_card/product_card.dart';
import '../widgets/products_widgets/product_search_bar.dart';
import '../widgets/products_widgets/products_empty_state.dart';
import '../widgets/products_widgets/products_tabs.dart';
import 'upsert_product_screen.dart';

final _pageStorageProvider = Provider((ref) => PageStorageBucket());

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({
    super.key,
    this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'المنتجات'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ProductsBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushTo(const UpsertProductScreen()),
        child: const Icon(Icons.add_circle),
      ),
    );
  }
}

class ProductsBody extends ConsumerWidget {
  const ProductsBody({
    super.key,
    this.showSimpleCount = false,
  });

  final bool showSimpleCount;

  @override
  Widget build(BuildContext context, ref) {
    final productsSearchAsync = ref.watch(productSearchProvider);
    final simpleProducts =
        ref.watch(productControllerProvider.select((s) => s.simpleProducts));
    return PageStorage(
      bucket: ref.read(_pageStorageProvider),
      child: Skeletonizer(
        enabled: productsSearchAsync.isLoading,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: showSimpleCount
              ? _ProductsBody(simpleProducts)
              : Column(
                  children: [
                    const ProductSearchBar(),
                    const SizedBox(height: 12),
                    const ProductsTabs(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: productsSearchAsync.when(
                        data: (filteredProducts) {
                          return _ProductsBody(
                            filteredProducts,
                          );
                        },
                        loading: () {
                          final fakeProducts = StoreProduct.fakeProducts;

                          return Skeletonizer(
                            child: _ProductsBody(fakeProducts),
                          );
                        },
                        error: (_, __) => Center(
                          child: Text(
                            'حدث خطأ أثناء تحميل المنتجات',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProductsBody extends ConsumerWidget {
  const _ProductsBody(this.products);
  final List<StoreProduct> products;

  Future<void> onRefresh(WidgetRef ref) async {
    final container = ref.container;
    await container
        .read(appSyncControllerProvider.notifier)
        .sync(isManual: true);

    await container
        .read(productControllerProvider.notifier)
        .loadStoreProducts();
  }

  @override
  Widget build(BuildContext context, ref) {
    final query = ref.watch(productQueryProvider);
    if (products.isEmpty) {
      return ProductsEmptyState(text: query.uiNotFoundText);
    }
    return RefreshIndicator(
      onRefresh: () => onRefresh(ref),
      child: ListView.separated(
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}
