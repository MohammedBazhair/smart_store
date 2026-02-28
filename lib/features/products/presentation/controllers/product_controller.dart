import 'package:flutter_riverpod/flutter_riverpod.dart';

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
