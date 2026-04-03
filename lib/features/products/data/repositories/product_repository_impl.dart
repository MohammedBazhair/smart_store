// ignore_for_file: unawaited_futures

import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/data/models/sync_state_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../../../errors/exceptions.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/entities/sub_entities/global_product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_local_data_source.dart';
import '../datasource/product_remote_data_source.dart';
import '../models/global_product_model.dart';
import '../models/store_product_key.dart';
import '../models/store_product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._localDatabase,
    this._remoteDatabase,
    this._connectivity,
    this._localCache,
    this._sync,
  );

  final ConnectivityService _connectivity;
  final LocalCacheService _localCache;
  final ProductLocalDataSource _localDatabase;
  final ProductRemoteDataSource _remoteDatabase;
  final SyncLocalDataSource _sync;

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final categories = await _localDatabase.fetchAllCategories();

      syncAllCategories();

      return categories;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<GlobalProduct>> getGlobalProducts() async {
    try {
      final products =
          await _localDatabase.fetchGlobalProducts(includeDeleted: false);

      syncAllProducts();
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
      return _localDatabase.getGlobalProductByBarcode(barcode);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value();
    }
  }

  @override
  Future<ProductsByIdentifier> getStoreProducts(String storeId) {
    try {
      return _localDatabase.fetchStoreProducts(
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
      return _localDatabase.fetchStoreProductById(key);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value();
    }
  }

  @override
  Future<List<StoreProduct>> searchProducts({
    required ProductQuery query,
    required String storeId,
  }) {
    try {
      return _localDatabase.searchStoreProducts(
        query: query,
        storeId: storeId,
      );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value([]);
    }
  }

  @override
  Future<List<StoreProduct>> getExpiredProducts(
    String storeId,
  ) {
    try {
      return _localDatabase.fetchExpiredStoreProducts(storeId);
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
      return _localDatabase.fetchNearExpiryStoreProducts(storeId, days);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value([]);
    }
  }

  @override
  Future<Result<StoreProduct>> addProduct(StoreProduct product) async {
    final barcode = product.globalProduct.barcode ?? '';
    final globalProduct = await getGlobalProductByBarcode(barcode);
    final globalProductId = globalProduct?.id ?? const Uuid().v4();

    final newProduct = product.copyWith(
      globalProduct: product.globalProduct.copyWith(id: globalProductId),
    );

    final model = StoreProductModel.fromEntity(newProduct);
    try {
      await _localDatabase.addStoreProduct(model);

      return SuccessState(newProduct);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState('فشل في إضافة المنتج');
    }
  }

  @override
  Future<Result<void>> updateProduct(Product product) async {
    try {
      if (product is StoreProduct) {
        final updatedProduct =
            product.copyWith(updatedAt: DateTime.now().toUtc());
        final updatedProductModel =
            StoreProductModel.fromEntity(updatedProduct);

        await _localDatabase.updateStoreProduct(updatedProductModel);
      } else if (product is GlobalProduct) {
        final updatedProduct =
            product.copyWith(updatedAt: DateTime.now().toUtc());
        final updatedProductModel =
            GlobalProductModel.fromEntity(updatedProduct);

        await _localDatabase.updateGlobalProduct(updatedProductModel);
      }
      return const SuccessState(null);
    } catch (e) {
      return const ErrorState('فشل في تحديث المنتج');
    }
  }

  Future<void> _initCategories() async {
    try {
      await syncAllCategories();
      await _localCache.setBool(
        key: 'isCategoriesDownloaded',
        value: true,
      );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  Future<void> _initProducts() async {
    try {
      await syncAllProducts();
      await _localCache.setBool(
        key: 'isProductsDownloaded',
        value: true,
      );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  @override
  Future<void> initializeDataFromNetwork() async {
    try {
      final hasConnection = await _connectivity.hasConnection();
      if (!hasConnection) throw const InternetException();

      final isCategoriesDownloaded =
          _localCache.getBool(key: 'isCategoriesDownloaded') ?? false;

      final isProductsDownloaded =
          _localCache.getBool(key: 'isProductsDownloaded') ?? false;

      if (!isCategoriesDownloaded) {
        await _initCategories();
      }

      if (!isProductsDownloaded) {
        await _initProducts();
      }
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  Future<void> _pushGlobalProductsChanges() async {
    try {
      final globalProductsChanges =
          await _sync.getTableChanges('global_products');
      Logger.debugLog(message: globalProductsChanges.toString());

      final inserts = <GlobalProductModel>[];
      final updates = <GlobalProductModel>[];

      for (final change in globalProductsChanges) {
        switch (change.operation) {
          case SyncOperation.delete:
            break;
          case SyncOperation.update:
            final product =
                await _localDatabase.fetchGlobalProductById(change.recordId);
            if (product != null) updates.add(product);

          case SyncOperation.insert:
            final product =
                await _localDatabase.fetchGlobalProductById(change.recordId);
            if (product != null) inserts.add(product);
        }
      }

      if (inserts.isNotEmpty) {
        await _remoteDatabase.addGlobalProducts(inserts);
      }

      if (updates.isNotEmpty) {
        await _remoteDatabase.updateGlobalProducts(updates);
      }

      await _sync.clearTablesChanges('global_products');
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  Future<void> _pushStoreProductsChanges() async {
    try {
      final storeProductsChanges = await _sync.getTableChanges('store_products');

      final inserts = <StoreProductModel>[];
      final updates = <StoreProductModel>[];
      final deletes = <StoreProductKey>[];

      for (final change in storeProductsChanges) {
        final productKey = StoreProductKey.fromJson(change.recordId);
        switch (change.operation) {
          case SyncOperation.delete:
            deletes.add(productKey);
          case SyncOperation.update:
            final product =
                await _localDatabase.fetchStoreProductById(productKey);
            if (product != null) updates.add(product);

          case SyncOperation.insert:
            final product =
                await _localDatabase.fetchStoreProductById(productKey);
            if (product != null) inserts.add(product);
        }
      }

      if (inserts.isNotEmpty) {
        await _remoteDatabase.addStoreProducts(inserts);
      }

      if (updates.isNotEmpty) {
        await _remoteDatabase.updateStoreProducts(updates);
      }

      if (deletes.isNotEmpty) {
        await _remoteDatabase.deleteStoreProducts(deletes);
      }

      await _sync.clearTablesChanges('store_products');
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  @override
  Future<void> syncAllProducts([String? storeId]) async {
    try {
      final selectedStoreId =
          storeId ?? _localCache.getString(key: AppConstants.lastStoreIdKey);

      if (!await _connectivity.hasConnection()) return;
      await _pushGlobalProductsChanges();
      await _pushStoreProductsChanges();

      final lastGlobalSync = await _sync.getLastSynced('global_products');
      final lastStoreProductsSync = await _sync.getLastSynced('store_products');

      final globalProducts =
          await _remoteDatabase.fetchGlobalProducts(lastSynced: lastGlobalSync);

      await _localDatabase.setGlobalProducts(globalProducts);

      final newDate = DateTime.now().toUtc();
      final newLastGlobalSync =
          SyncStateModel(tableName: 'global_products', lastSynced: newDate);
      await _sync.saveLastSynced(newLastGlobalSync);

      if (selectedStoreId == null) return;

      final storeProducts = await _remoteDatabase.fetchStoreProducts(
        storeId: selectedStoreId,
        lastSynced: lastStoreProductsSync,
      );

      await _localDatabase.setStoreProducts(storeProducts.values.toList());

      final newLastStoreProductsSync =
          SyncStateModel(tableName: 'store_products', lastSynced: newDate);
      await _sync.saveLastSynced(newLastStoreProductsSync);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  @override
  Future<void> syncAllCategories() async {
    try {
      if (!await _connectivity.hasConnection()) return;

      final lastCategoriesSync = await _sync.getLastSynced('categories');

      final categories =
          await _remoteDatabase.fetchAllCategories(lastCategoriesSync);

      await _localDatabase.setAllCategories(categories);

      final newDate = DateTime.now().toUtc();
      final newLastCategoriesSync =
          SyncStateModel(tableName: 'categories', lastSynced: newDate);

      await _sync.saveLastSynced(newLastCategoriesSync);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  @override
  Future<void> deleteProduct(StoreProductKey key) async {
    await _localDatabase.deleteStoreProduct(key);
  }
}
