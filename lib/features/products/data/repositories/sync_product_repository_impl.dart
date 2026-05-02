import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/data/models/sync_state_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../domain/repositories/sync_product_repository.dart';
import '../datasource/category_local_data_source.dart';
import '../datasource/global_product_local_data_source.dart';
import '../datasource/product_remote_data_source.dart';
import '../datasource/store_product_local_data_source.dart';
import '../models/global_product_model.dart';
import '../models/store_product_key.dart';
import '../models/store_product_model.dart';

class SyncProductRepositoryImpl implements SyncProductRepository {
  SyncProductRepositoryImpl(
    this._localCache,
    this._sync,
    this._connectivity,
    this._localGlobalProductDb,
    this._remoteDatabase,
    this._localStoreProductDb,
    this._localCategoryDb,
  );

  final LocalCacheService _localCache;
  final GlobalProductLocalDataSource _localGlobalProductDb;
  final ConnectivityService _connectivity;
  final ProductRemoteDataSource _remoteDatabase;
  final StoreProductLocalDataSource _localStoreProductDb;
  final CategoryLocalDataSource _localCategoryDb;

  final SyncLocalDataSource _sync;

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
      // ignore: unawaited_futures
      if (!hasConnection) initializeDataFromNetwork();

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

      await _localGlobalProductDb.setGlobalProducts(globalProducts);

      final newDate = DateTime.now().toUtc();
      final newLastGlobalSync =
          SyncStateModel(tableName: 'global_products', lastSynced: newDate);
      await _sync.saveLastSynced(newLastGlobalSync);

      if (selectedStoreId == null) return;

      final storeProducts = await _remoteDatabase.fetchStoreProducts(
        storeId: selectedStoreId,
        lastSynced: lastStoreProductsSync,
      );

      await _localStoreProductDb
          .setStoreProducts(storeProducts.values.toList());

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

      await _localCategoryDb.setAllCategories(categories);

      final newDate = DateTime.now().toUtc();
      final newLastCategoriesSync =
          SyncStateModel(tableName: 'categories', lastSynced: newDate);

      await _sync.saveLastSynced(newLastCategoriesSync);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  Future<void> _pushGlobalProductsChanges() async {
    try {
      final globalProductsChanges =
          await _sync.getTableChanges('global_products');

      final inserts = <GlobalProductModel>[];
      final updates = <GlobalProductModel>[];

      for (final change in globalProductsChanges) {
        switch (change.operation) {
          case SyncOperation.delete:
            break;
          case SyncOperation.update:
            final product = await _localGlobalProductDb
                .fetchGlobalProductById(change.recordId);
            if (product != null) updates.add(product);

          case SyncOperation.insert:
            final product = await _localGlobalProductDb
                .fetchGlobalProductById(change.recordId);
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
      final storeProductsChanges =
          await _sync.getTableChanges('store_products');

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
                await _localStoreProductDb.fetchStoreProductById(productKey);
            if (product != null) updates.add(product);

          case SyncOperation.insert:
            final product =
                await _localStoreProductDb.fetchStoreProductById(productKey);
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
  Future<void> resetCacheFlags() async {
        // 1️⃣ Reset cache flags
      await _localCache.remove(key: 'isCategoriesDownloaded');
      await _localCache.remove(key: 'isProductsDownloaded');

    
  }
}
