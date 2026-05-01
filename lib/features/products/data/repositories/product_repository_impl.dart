import 'package:uuid/uuid.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/entities/sub_entities/global_product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sync_product_repository.dart';
import '../datasource/category_local_data_source.dart';
import '../datasource/global_product_local_data_source.dart';
import '../datasource/product_remote_data_source.dart';
import '../datasource/store_product_local_data_source.dart';
import '../models/global_product_model.dart';
import '../models/store_product_key.dart';
import '../models/store_product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._connectivity,
    this._localCache,
    this._localCategoryDb,
    this._localGlobalProductDb,
    this._localStoreProductDb,
    this._remoteDatabase,
    this._syncLocal,
    this._syncRepo,
  );

  final ConnectivityService _connectivity;
  final LocalCacheService _localCache;
  final CategoryLocalDataSource _localCategoryDb;
  final GlobalProductLocalDataSource _localGlobalProductDb;
  final StoreProductLocalDataSource _localStoreProductDb;
  final ProductRemoteDataSource _remoteDatabase;
  final SyncLocalDataSource _syncLocal;
  final SyncProductRepository _syncRepo;

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final categories = await _localCategoryDb.fetchAllCategories();

      // ignore: unawaited_futures
      _syncRepo.syncAllCategories();

      return categories;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<GlobalProduct>> getGlobalProducts() async {
    try {
      final products = await _localGlobalProductDb.fetchGlobalProducts(
        includeDeleted: false,
      );

      // ignore: unawaited_futures
     _syncRepo.syncAllProducts();
      return products;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);

      return [];
    }
  }

  @override
  Future<GlobalProduct?> getGlobalProductByBarcode(
    String barcode,
  ) {
    try {
      return _localGlobalProductDb.getGlobalProductByBarcode(barcode);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value();
    }
  }

  @override
  Future<ProductsByIdentifier> getStoreProducts(String storeId) {
    try {
      return _localStoreProductDb.fetchStoreProducts(
        storeId: storeId,
        includeDeleted: false,
      );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value({});
    }
  }

  @override
  Future<StoreProduct?> getStoreProductById(StoreProductKey key) {
    try {
      return _localStoreProductDb.fetchStoreProductById(key);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value();
    }
  }


  @override
  Future<List<StoreProduct>> getExpiredProducts(
    String storeId,
  ) {
    try {
      return _localStoreProductDb.fetchExpiredStoreProducts(storeId);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value([]);
    }
  }

  @override
  Future<List<StoreProduct>> getNearExpiryProducts(
    String storeId,
    int days,
  ) {
    try {
      return _localStoreProductDb.fetchNearExpiryStoreProducts(storeId, days);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value([]);
    }
  }

// TODO: Make sure correct logic
  @override
  Future<Result<StoreProduct>> addProduct(StoreProduct product) async {
    final barcode = product.globalProduct.barcode ?? '';
    final globalProduct = await getGlobalProductByBarcode(barcode);
    final globalProductId = globalProduct?.id ?? const Uuid().v4();

    final newProduct = product.copyWith(
      globalProduct: product.globalProduct.copyWith(id: globalProductId),
    );

    final storeProductModel = StoreProductModel.fromEntity(newProduct);
    final globalProductModel =
        GlobalProductModel.fromEntity(newProduct.globalProduct);
    try {
      await _localGlobalProductDb.addGlobalProduct(globalProductModel);
      await _localStoreProductDb.addStoreProduct(storeProductModel);

      return SuccessState(newProduct);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState('فشل في إضافة المنتج');
    }
  }

// TODO: Make sure correct logic
  @override
  Future<Result<void>> updateProduct(StoreProduct product) async {
    try {
      final updatedProduct =
          product.copyWith(updatedAt: DateTime.now().toUtc());
      final updatedProductModel = StoreProductModel.fromEntity(updatedProduct);

      await _localStoreProductDb.updateStoreProduct(updatedProductModel);
      final updatedGlobalProduct =
          product.copyWith(updatedAt: DateTime.now().toUtc()).globalProduct;
      final updatedGlobalProductModel =
          GlobalProductModel.fromEntity(updatedGlobalProduct);

      await _localGlobalProductDb
          .updateGlobalProduct(updatedGlobalProductModel);

      return const SuccessState(null);
    } catch (e) {
      return const ErrorState('فشل في تحديث المنتج');
    }
  }

  @override
  Future<void> deleteProduct(StoreProductKey key) async {
    await _localStoreProductDb.deleteStoreProduct(key);
  }

  @override
  Future<List<StoreProduct>> getWithoutBarcodeProducts(String storeId) async {
    final result = await _localStoreProductDb.fetchStoreProducts(
      storeId: storeId,
      includeDeleted: false,
      onlyWithoutBarcode: true,
    );

    return result.values.toList();
  }
}
