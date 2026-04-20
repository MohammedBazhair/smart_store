import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../../products/presentation/controllers/product_provider.dart';

class QuickProductsController extends Notifier<ProductsByIdentifier> {
  LocalCacheService get _cacheService => ref.read(localCacheServiceProvider);

  @override
  ProductsByIdentifier build() => _getQuickProducts();

  ProductsByIdentifier _getQuickProducts() {
    final ids =
        _cacheService.getStringList(key: AppConstants.quickProductsIdsKey) ??
            [];

    final allProducts = ref.read(productControllerProvider).products;

    final entries = ids.map((id) => MapEntry(id, allProducts[id]));
    final quickProducts = entries.where((m) => m.value != null);

   return Map.fromIterable(quickProducts);
  }

  Future<void> toggleProduct(StoreProduct product) async {
    final ids =
        _cacheService.getStringList(key: AppConstants.quickProductsIdsKey) ??
            [];

    final productId = product.id!;

    final isTapToAdd = !ids.contains(productId);

    isTapToAdd ? ids.add(productId) : ids.remove(productId);

    final copiedProducts = {...state};

    if (isTapToAdd) {
      copiedProducts[productId] = product;
    } else {
      copiedProducts.remove(productId);
    }
   

    state = copiedProducts;

    await _cacheService.setStringList(
      key: AppConstants.quickProductsIdsKey,
      value: ids,
    );
  }
}
