import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/log.dart';
import '../../../../errors/result.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/store_product.dart';
import 'product_provider.dart';
import 'product_state.dart';

class ProductManagementController extends Notifier<ProductManagementState> {
  @override
  ProductManagementState build() {
    return ProductManagementState(products: [], categories: []);
  }

  /// تحديث قائمة المنتجات
  void _invalidate() {
    ref.invalidate(productsProvider);
    ref.invalidate(expiredProductsProvider);
    ref.invalidate(nearExpiryProductsProvider);
  }

  Future<void> initialize() async {
    final categories = await getCategories();
    final products = await getSellerProducts();

    state = ProductManagementState(products: products, categories: categories);
    Logger.debugLog(
      message:
          'ProductManagementController initialized with ${products.length} products and ${categories.length} categories',
    );
  }

  Future<List<Category>> getCategories() async {
    final categories =
        await ref.read(productRepositoryProvider).getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  Future<List<StoreProduct>> getSellerProducts() async {
    final products =
        await ref.read(productRepositoryProvider).getAllProducts('');

    return products;
  }

  Future<Result<void>> addProduct(
    StoreProduct product,
  ) async {
    final productRepository = ref.read(productRepositoryProvider);

    final productResult = await productRepository.addProduct(product);

    if (productResult is! SuccessState<String>) return productResult;

    final alertService = ref.read(alertServiceProvider);
    await alertService.scheduleProductAlerts(product);

    _invalidate();
    return productResult;
  }

  Future<Result<void>> updateProduct({
    required StoreProduct oldProduct,
    required StoreProduct newProduct,
  }) async {
    final repository = ref.read(productRepositoryProvider);

    final result = await repository.updateProduct(newProduct);

    if (result is ErrorState<void>) return result;

    final alertService = ref.read(alertServiceProvider);

    if (oldProduct.expiryDate != newProduct.expiryDate) {
      await alertService.cancelProductAlerts(newProduct);

      // إعادة الجدولة
      await alertService.scheduleProductAlerts(newProduct);
    }

    _invalidate();
    ref.invalidate(productByIdProvider(newProduct.id!));

    return result;
  }
}
