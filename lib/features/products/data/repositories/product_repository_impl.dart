import 'package:uuid/uuid.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/database/local/local_database_service.dart';
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
import '../models/product_change_type.dart';
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
    this._db,
  );

  final ConnectivityService _connectivity;
  final LocalCacheService _localCache;
  final CategoryLocalDataSource _localCategoryDb;
  final GlobalProductLocalDataSource _localGlobalProductDb;
  final StoreProductLocalDataSource _localStoreProductDb;
  final ProductRemoteDataSource _remoteDatabase;
  final SyncLocalDataSource _syncLocal;
  final SyncProductRepository _syncRepo;
  final LocalDatabaseService _db;

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

  @override
  Future<Result<StoreProduct>> addProduct(StoreProduct product) async {
    try {
      final barcode = product.globalProduct.barcode;
      String globalProductId = const Uuid().v4();

      if (product.hasBarcode) {
        final existing = await getGlobalProductByBarcode(barcode!);

        if (existing != null) globalProductId = existing.id!;
      }

      final newProduct = product.copyWith(
        globalProduct: product.globalProduct.copyWith(id: globalProductId),
      );

      final storeProductModel = StoreProductModel.fromEntity(newProduct);

      await _localStoreProductDb.addStoreProduct(storeProductModel);

      return SuccessState(newProduct);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState('فشل في إضافة المنتج');
    }
  }

  @override
  Future<Result<void>> updateProduct(
    StoreProduct product,
    ProductChangeType changeType,
  ) async {
    try {
      final now = DateTime.now().toUtc();

      final updatedProduct =
          changeType.storeChanged ? product.copyWith(updatedAt: now) : product;
      final updatedProductModel = StoreProductModel.fromEntity(updatedProduct);

      final globalProduct = changeType.globalChanged
          ? product.globalProduct.copyWith(updatedAt: now)
          : product.globalProduct;
      final globalProductModel = GlobalProductModel.fromEntity(globalProduct);

      await _db.transaction(
        (txn) async {
          if (changeType.globalChanged) {
            await _localGlobalProductDb.updateGlobalProduct(
              product: globalProductModel,
              transaction: txn,
            );
          }

          if (changeType.storeChanged) {
            await _localStoreProductDb.updateStoreProduct(
              product: updatedProductModel,
              transaction: txn,
            );
          }
        },
      );

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
