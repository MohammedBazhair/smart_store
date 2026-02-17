import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../errors/result.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../domain/entities/seller_product.dart';
import 'product_provider.dart';

class ProductController extends Notifier<void> {
  @override
  void build() {}

  /// تحديث قائمة المنتجات
  void _invalidate() {
    ref.invalidate(productsProvider);
    ref.invalidate(expiredProductsProvider);
    ref.invalidate(nearExpiryProductsProvider);
  }

  Future<Result<void>> addProduct(
    SellerProduct product,
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
    required SellerProduct oldProduct,
    required SellerProduct newProduct,
  }) async {
    final repository = ref.read(productRepositoryProvider);
    final updatedProduct = newProduct.copyWith(updatedAt: DateTime.now());

    final result = await repository.updateProduct(updatedProduct);

    if (result is ErrorState<void>) return result;

    final alertService = ref.read(alertServiceProvider);

    if (oldProduct.expiryDate != updatedProduct.expiryDate) {
      await alertService.cancelProductAlerts(updatedProduct);

      // إعادة الجدولة
      await alertService.scheduleProductAlerts(updatedProduct);
    }

    _invalidate();
    ref.invalidate(productByIdProvider(updatedProduct.id!));

    return result;
  }

  Future<Result<void>> deleteProduct(int id) async {
    final repository = ref.read(productRepositoryProvider);
    final product = await repository.getProductById(id);
    final result = await repository.deleteProduct(id);

    if (result is! SuccessState<void>) return result;
    if (product is! SuccessState<SellerProduct>) return result;
    final alertService = ref.read(alertServiceProvider);
    await alertService.cancelProductAlerts(product.data);

    _invalidate();

    return result;
  }
}

final productByIdProvider = FutureProvider.family<SellerProduct?, String>(
  (ref, id) async {
    final result =
        await ref.watch(productRepositoryProvider).getProductById(id);
    if (result is SuccessState<SellerProduct>) return result.data;
    return null;
  },
);

/// Provider للـ ProductController
final productControllerProvider = NotifierProvider<ProductController, void>(() {
  return ProductController();
});
