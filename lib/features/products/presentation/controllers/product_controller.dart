import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/shared/domain/entities/permission.dart';
import '../../../../core/shared/domain/services/permission_service.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/exceptions.dart';
import '../../../../errors/result.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../data/models/product_change_type.dart';
import '../../data/models/store_product_key.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sync_product_repository.dart';
import 'product_management_state.dart';
import 'product_provider.dart';

class ProductManagementController extends Notifier<ProductManagementState> {
  PermissionService get _permissionService =>
      ref.read(permissionServiceProvider);

  ProductRepository get _productRepo => ref.read(productRepositoryProvider);
  SyncProductRepository get _syncProductRepo =>
      ref.read(syncProductRepositoryProvider);

  @override
  ProductManagementState build() {
    return const ProductManagementState();
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    final storeId = ref.read(storeControllerProvider).state.selectedStoreId;

    await _syncProductRepo.syncAllCategories();
    if (storeId != null) await _syncProductRepo.syncAllProducts(storeId);

    final categories = await getCategories();
    final products = await getStoreProducts();

    state = state.copyWith(
      products: products,
      categories: categories,
      isLoading: false,
    );
  }

  Future<List<Category>> getCategories() async {
    final categories = await _productRepo.getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  Future<void> loadStoreProducts() async {
    final products = await getStoreProducts();

    state = state.copyWith(products: products);
  }

  Future<ProductsByIdentifier> getStoreProducts() async {
    try {
      if (!_permissionService.can(PermissionTask.viewStoreProducts)) return {};
      final storeId = ref.read(storeControllerProvider).state.selectedStoreId;

      if (storeId == null) return {};

      final products = await _productRepo.getStoreProducts(storeId);

      return products;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return {};
    }
  }

  Future<({String productName, bool isProductExists})> isBarcodeExistsInStore(
    String? barcode,
  ) async {
    if (barcode == null) return (productName: '', isProductExists: false);

    final globalProduct = await _productRepo.getGlobalProductByBarcode(barcode);

    if (globalProduct == null) {
      return (productName: '', isProductExists: false);
    }

    final existsInStore = state.products.containsKey(globalProduct.id);

    return (productName: globalProduct.name, isProductExists: existsInStore);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final globalProduct = await _productRepo.getGlobalProductByBarcode(
      barcode,
    );

    if (globalProduct == null) return null;

    final storeProduct = state.products[globalProduct.id];

    return storeProduct ?? globalProduct;
  }

  Future<Result<void>> addProduct(
    StoreProduct product,
  ) async {
    final barcode = product.globalProduct.barcode;
    final (:productName, :isProductExists) =
        await isBarcodeExistsInStore(barcode);

    if (isProductExists) {
      return ErrorState(' المنتج ($productName) مكرر وموجود مسبقا');
    }

    final result = await _productRepo.addProduct(product);

    if (result is ErrorState<StoreProduct>) {
      return const ErrorState('فشلت عملية إنشاء المنتج');
    }

    final storeProduct = (result as SuccessState<StoreProduct>).data;
    final alertService = ref.read(alertServiceProvider);
    await alertService.scheduleProductAlerts(storeProduct);

    final copiedProducts = {...state.products};

    final key = storeProduct.id!;
    copiedProducts[key] = storeProduct;

    state = state.copyWith(products: copiedProducts);
    await ref.read(audioControllerProvider.notifier).playSuccessResult();
    _refreshRefs();
    return const SuccessState(null);
  }

  Future<Result<void>> updateProduct({
    required StoreProduct oldProduct,
    required StoreProduct newProduct,
  }) async {
    if (!_permissionService.can(PermissionTask.updateProduct)) {
      return const ErrorState('لا تمتلك صلاحية تعديل بيانات المنتجات');
    }

    final changeType =
        ProductChangeType.detectChanges(oldP: oldProduct, newP: newProduct);
    final result = await _productRepo.updateProduct(newProduct, changeType);

    if (result is ErrorState<void>) return result;

    final alertService = ref.read(alertServiceProvider);

    if (oldProduct.expiryDate != newProduct.expiryDate) {
      await alertService.cancelProductAlerts(newProduct);

      // إعادة الجدولة
      await alertService.scheduleProductAlerts(newProduct);
    }

    final productId = newProduct.id!;

    final copiedProducts = {...state.products};

    copiedProducts.update(
      productId,
      (value) => newProduct,
      ifAbsent: () => newProduct,
    );

    state = state.copyWith(products: copiedProducts);
    _refreshRefs();
    return result;
  }

  Future<StoreProduct?> getProductById(String productId) async {
    try {
      final storeId = ref.read(
        storeControllerProvider.select((s) => s.state.selectedStoreId),
      );

      final productKey =
          StoreProductKey(storeId: storeId!, productId: productId);
      final result = await _productRepo.getStoreProductById(productKey);

      return result;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return null;
    }
  }

  Future<Result<void>> deleteProduct(StoreProduct product) async {
    try {
      final hasPermission =
          _permissionService.can(PermissionTask.deleteProduct);
      if (!hasPermission) {
        throw const PermissionsException('لا توجد لديك صلاحية حذف المنتجات');
      }
      final storeId = ref.read(storeControllerProvider).state.selectedStoreId;

      final productKey = StoreProductKey(
        storeId: storeId!,
        productId: product.globalProduct.id!,
      );
      await _productRepo.deleteProduct(productKey);
      final copied = {...state.products};
      copied.remove(product.id);

      state = state.copyWith(products: copied);
      _refreshRefs();
      return const SuccessState(null);
    } on AppException catch (e) {
      return ErrorState(e.message);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState('حصلت مشكلة أثناء حذف المنتج');
    }
  }

  void _refreshRefs() {
    ref.read(productSearchControllerProvider.notifier).reset();
  }
}
