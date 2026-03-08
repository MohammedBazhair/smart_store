import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../errors/result.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import 'product_provider.dart';
import 'product_state.dart';

class ProductManagementController extends Notifier<ProductManagementState> {
  @override
  ProductManagementState build() {
    return const ProductManagementState();
  }

  Future<void> initialize() async {
    final repo = ref.read(productRepositoryProvider);
    final storeId = ref.watch(storeControllerProvider).state.selectedStoreId;
    final categories = await getCategories();
    final products = await getStoreProducts();
    final expiredProducts = await repo.getExpiredProducts(storeId!);
    final nearbyExpiredProducts = await repo.getNearExpiryProducts(storeId, 30);

    state = state.copyWith(
      products: products,
      expiredProducts: expiredProducts,
      nearbyExpiredProducts: nearbyExpiredProducts,
      categories: categories,
    );
  }

  Future<List<Category>> getExchangeRates() async {
    final exchangeRates =
        await ref.read(productRepositoryProvider).getAllCategories();
    return exchangeRates;
  }

  Future<List<Category>> getCategories() async {
    final categories =
        await ref.read(productRepositoryProvider).getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  Future<void> loadStoreProducts() async {
    final products = await getStoreProducts();

    state = state.copyWith(products: products);
  }

  Future<ProductsByIdentifier> getStoreProducts() async {
    try {
      final storeId = ref.watch(storeControllerProvider).state.selectedStoreId;

      if (storeId == null) return {};

      final products =
          await ref.read(productRepositoryProvider).getStoreProducts(storeId);

      return products;
    } catch (e) {
      Logger.debugLog(error: e);
      return {};
    }
  }

  bool isBarcodeExistsInStore(String? barcode) {
    if (barcode == null) return false;

    return state.products.containsKey(barcode);
  }

  Future<Result<void>> addProduct(
    StoreProduct product,
  ) async {
    final barcode = product.globalProduct.barcode;
    if (isBarcodeExistsInStore(barcode)) {
      return const ErrorState('هذا المنتج مكرر وموجود مسبقا');
    }

    final productRepository = ref.read(productRepositoryProvider);

    final result = await productRepository.addProduct(product);

    if (result is SuccessState<StoreProduct>) {
      final alertService = ref.read(alertServiceProvider);
      await alertService.scheduleProductAlerts(result.data);
      await loadStoreProducts();
      return const SuccessState(null);
    }

    return const ErrorState('فشلت عملية إنشاء المنتج');
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

    await loadStoreProducts();
    return result;
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final storeProduct = state.products[barcode];
    if (storeProduct != null) return storeProduct;

    final productRepo = ref.read(productRepositoryProvider);

    // التحقق من وجود المنتج
    final globalProduct = await productRepo.getGlobalProductByBarcode(
      barcode,
    );

    return globalProduct;
  }

  Future<StoreProduct?> getProductById(String productId) async {
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final storeId = ref.watch(
        storeControllerProvider.select((s) => s.state.selectedStoreId),
      );

      final result = await productRepo.getProductById(
        productId: productId,
        storeId: storeId!,
      );

      if (result is SuccessState<StoreProduct>) return result.data;

      return null;
    } on Exception catch (e) {
      Logger.debugLog(error: e);
      return null;
    }
  }

  Future<List<StoreProduct>> searchProducts(ProductQuery query) async {
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final storeId = ref.watch(storeControllerProvider).state.selectedStoreId!;

      final products = await productRepo.searchProducts(
        query: query.search,
        storeId: storeId,
      );

      Logger.debugLog(message: products.toString());
      if (!query.hasCategory) return products;

      return products
          .where((p) => p.globalProduct.category.id == query.category?.id)
          .toList();
    } catch (e) {
      Logger.debugLog(error: e);
      return [];
    }
  }
}
