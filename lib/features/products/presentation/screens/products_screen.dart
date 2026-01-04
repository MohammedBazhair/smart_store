import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../shared/providers/ui_providers.dart';
import '../../domain/product.dart';
import '../controllers/product_provider.dart';
import '../widgets/products_widgets/product_filter_dialog.dart';
import '../widgets/products_widgets/product_search_bar.dart';
import '../widgets/products_widgets/products_empty_state.dart';
import '../widgets/products_widgets/products_list.dart';
import 'add_product_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key, required this.productsProvider, this.title});
  final FutureProvider<List<Product>> productsProvider;
  final String? title;
  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ProductCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'المنتجات'),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Skeletonizer(
            enabled: ref.watch(isLoadingProvider(IsLoading.search)),
            child: Column(
              children: [
                // شريط البحث
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: ProductSearchBar(
                        controller: _searchController,
                        searchQuery: _searchQuery,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        onClear: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
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

                // قائمة المنتجات
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // اختيار الـ Provider المناسب
                      final productsAsync = isSearching
                          ? ref.watch(searchProductsProvider(_searchQuery))
                          : ref.watch(widget.productsProvider);

                      return productsAsync.when(
                        loading: () {
                          // shimmer أثناء التحميل
                          final fakeProducts =
                              List.generate(8, (_) => Product.fake());
                          return ProductsList(
                            products: fakeProducts,
                            isLoading: true,
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
                        data: (data) {
                          // فلترة حسب الكاتيجوري
                          final filteredProducts = _selectedCategory == null
                              ? data
                              : data
                                  .where((p) => p.category == _selectedCategory)
                                  .toList();

                          if (filteredProducts.isEmpty) {
                            return ProductsEmptyState(isSearching: isSearching);
                          }

                          return ProductsList(products: filteredProducts);
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
        initialCategory: _selectedCategory,
        onApply: (category) => setState(() => _selectedCategory = category),
      ),
    );
  }
}
