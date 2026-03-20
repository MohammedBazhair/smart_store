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
import '../../data/models/store_product_key.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store_product.dart';
import 'product_provider.dart';
import 'product_state.dart';

class ProductManagementController extends Notifier<ProductManagementState> {
  late final PermissionService _permissionService;

  @override
  ProductManagementState build() {
    _permissionService = ref.read(permissionServiceProvider);
    return const ProductManagementState();
  }

  Future<void> initialize() async {
    final repo = ref.read(productRepositoryProvider);
    final storeId = ref.watch(storeControllerProvider).state.selectedStoreId;

    await repo.syncAllProducts(storeId);

    final categories = await getCategories();
    final products = await getStoreProducts();

    Logger.debugLog(message: products.toString());

    final expiredProducts = storeId != null
        ? await repo.getExpiredProducts(storeId)
        : <StoreProduct>[];
    final nearbyExpiredProducts = storeId != null
        ? await repo.getNearExpiryProducts(storeId, 30)
        : <StoreProduct>[];

    state = state.copyWith(
      products: products,
      expiredProducts: expiredProducts,
      nearbyExpiredProducts: nearbyExpiredProducts,
      categories: categories,
    );
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
      if (!_permissionService.can(PermissionTask.viewStoreProducts)) return {};
      final storeId = ref.watch(storeControllerProvider).state.selectedStoreId;

      if (storeId == null) return {};

      final products =
          await ref.read(productRepositoryProvider).getStoreProducts(storeId);

      return products;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
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

    if (result is ErrorState<StoreProduct>) {
      return const ErrorState('فشلت عملية إنشاء المنتج');
    }

    final storeProduct = (result as SuccessState<StoreProduct>).data;
    final alertService = ref.read(alertServiceProvider);
    await alertService.scheduleProductAlerts(storeProduct);

    final copiedProducts = {...state.products};

    final key =
        storeProduct.globalProduct.barcode ?? storeProduct.globalProduct.id;
    copiedProducts[key!] = storeProduct;

    state = state.copyWith(products: copiedProducts);
    await ref.read(audioControllerProvider.notifier).playSuccessResult();

    return const SuccessState(null);
  }

  Future<Result<void>> updateProduct({
    required StoreProduct oldProduct,
    required StoreProduct newProduct,
  }) async {
    final repository = ref.read(productRepositoryProvider);

    if (!_permissionService.can(PermissionTask.updateProduct)) {
      return const ErrorState('لا تمتلك صلاحية تعديل بيانات المنتجات');
    }

    final result = await repository.updateProduct(newProduct);

    if (result is ErrorState<void>) return result;

    final alertService = ref.read(alertServiceProvider);

    if (oldProduct.expiryDate != newProduct.expiryDate) {
      await alertService.cancelProductAlerts(newProduct);

      // إعادة الجدولة
      await alertService.scheduleProductAlerts(newProduct);
    }

    final oldKey =
        oldProduct.globalProduct.barcode ?? oldProduct.globalProduct.id!;
    final copiedProducts = {...state.products}..remove(oldKey);

    final newKey =
        newProduct.globalProduct.barcode ?? newProduct.globalProduct.id!;
    copiedProducts[newKey] = newProduct;

    state = state.copyWith(products: copiedProducts);
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

      final productKey =
          StoreProductKey(storeId: storeId!, productId: productId);
      final result = await productRepo.getStoreProductById(productKey);

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
      final productRepo = ref.read(productRepositoryProvider);
      final storeId = ref.read(storeControllerProvider).state.selectedStoreId;

      final productKey = StoreProductKey(
        storeId: storeId!,
        productId: product.globalProduct.id!,
      );
      await productRepo.deleteProduct(productKey);

      final copiedProducts = {...state.products};

      final productKeyInMap =
          product.globalProduct.barcode ?? product.globalProduct.id!;
      copiedProducts.remove(productKeyInMap);

      state = state.copyWith(products: copiedProducts);
      return const SuccessState(null);
    } on AppException catch (e) {
      return ErrorState(e.message);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState('حصلت مشكلة أثناء حذف المنتج');
    }
  }
}
