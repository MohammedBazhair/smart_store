import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../../products/presentation/controllers/product_provider.dart';

class QuickProductsController extends Notifier<List<StoreProduct>> {
  @override
  List<StoreProduct> build() {
    _loadQuickProducts();
    // Re-evaluate if products overall change.
    ref.listen(productControllerProvider, (prev, next) {
      if (prev?.products != next.products) {
        _loadQuickProducts();
      }
    });
    return state;
  }

  void _loadQuickProducts() {
    final prefs = ref.read(sharedPreferencesProvider);
    final ids = prefs.getStringList(AppConstants.quickProductsIdsKey) ?? [];
    
    final allProducts = ref.read(productControllerProvider).products;
    
    final quickProducts = <StoreProduct>[];
    for (final id in ids) {
      if (allProducts.containsKey(id)) {
        quickProducts.add(allProducts[id]!);
      }
    }
    state = quickProducts;
  }

  Future<void> toggleProduct(StoreProduct product) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final ids = List<String>.from(
      prefs.getStringList(AppConstants.quickProductsIdsKey) ?? [],
    );
    
    final productId = product.id!;
    if (ids.contains(productId)) {
      ids.remove(productId);
    } else {
      ids.add(productId);
    }
    
    await prefs.setStringList(AppConstants.quickProductsIdsKey, ids);
    _loadQuickProducts();
  }
}

final quickProductsProvider =
    NotifierProvider<QuickProductsController, List<StoreProduct>>(() {
  return QuickProductsController();
});
