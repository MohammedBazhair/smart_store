import 'package:uuid/uuid.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/data/models/sync_state_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
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
      final hasConnection = await _connectivity.hasConnection();
      final result = hasConnection
          ? await _remoteDatabase.fetchAllCategories()
          : await _localDatabase.fetchAllCategories();

      await _localDatabase.setAllCategories(result);
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<GlobalProduct>> getGlobalProducts() async {
    try {
      final hasConnection = await _connectivity.hasConnection();
      final products = hasConnection
          ? await _remoteDatabase.fetchGlobalProducts(includeDeleted: false)
          : await _localDatabase.fetchGlobalProducts(includeDeleted: false);

      if (hasConnection) {
        await _localDatabase.setGlobalProducts(products);
      }
      return products;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<GlobalProduct?> getGlobalProductByBarcode(
    String barcode,
  ) async {
    final hasConnection = await _connectivity.hasConnection();

    final product = hasConnection
        ? await _remoteDatabase.fetchGlobalProductByBarcode(barcode)
        : await _localDatabase.getGlobalProductByBarcode(barcode);

    return product;
  }

  @override
  Future<ProductsByIdentifier> getStoreProducts(String storeId) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final products = hasConnection
          ? await _remoteDatabase.fetchStoreProducts(
              storeId: storeId,
              includeDeleted: false,
            )
          : await _localDatabase.fetchStoreProducts(
              storeId: storeId,
              includeDeleted: false,
            );

      if (hasConnection) {
        await _localDatabase.setStoreProducts(products.values.toList());
      }

      return products;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<StoreProduct?> getStoreProductById(StoreProductKey key) async {
    try {
      final hasConnection = await _connectivity.hasConnection();
      final result = hasConnection
          ? await _remoteDatabase.fetchStoreProductById(key)
          : await _localDatabase.fetchStoreProductById(key);

      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<StoreProduct>> searchProducts({
    required String query,
    required String storeId,
  }) async {
    try {
      return _localDatabase.searchStoreProducts(
        query: query,
        storeId: storeId,
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StoreProduct>> getExpiredProducts(
    String storeId,
  ) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.fetchExpiredStoreProducts(storeId)
          : await _localDatabase.fetchExpiredStoreProducts(storeId);

      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StoreProduct>> getNearExpiryProducts(
    String storeId,
    int days,
  ) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.fetchNearExpiryStoreProducts(storeId, days)
          : await _localDatabase.fetchNearExpiryStoreProducts(storeId, days);

      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Result<StoreProduct>> addProduct(StoreProduct product) async {
    final barcode = product.globalProduct.barcode ?? '';
    final globalProduct = await getGlobalProductByBarcode(barcode);
    final globalProductId =
        globalProduct != null ? globalProduct.id : const Uuid().v4();

    final newProduct = product.copyWith(
      globalProduct: product.globalProduct.copyWith(id: globalProductId),
    );

    final model = StoreProductModel.fromEntity(newProduct);
    try {
      final hasConnection = await _connectivity.hasConnection();
      if (hasConnection) await _remoteDatabase.addStoreProduct(model);

      await _localDatabase.addStoreProduct(model, hasConnection);
      return SuccessState(newProduct);
    } catch (e) {
      Logger.debugLog(error: e);
      return ErrorState('فشل في إضافة المنتج: ${e.toString()}');
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
        if (await _connectivity.hasConnection()) {
          await _remoteDatabase.updateStoreProduct(updatedProductModel);
        }

        await _localDatabase.updateStoreProduct(updatedProductModel);
      } else {}
      return const SuccessState(null);
    } catch (e) {
      return const ErrorState('فشل في تحديث المنتج');
    }
  }

  @override
  Future<void> initializeDataFromNetwork() async {
    try {
      final isDownloaded =
          _localCache.getBool(key: 'isDownloadedInit') ?? false;
      if (isDownloaded) return;

      if (!await _connectivity.hasConnection()) {
        throw Exception('No internet connection');
      }

      final categoriesResult = await getAllCategories();

      if (categoriesResult.isEmpty) {
        throw Exception('Categories not loaded');
      }

      await getGlobalProducts();

      await _localCache.setBool(key: 'isDownloadedInit', value: true);
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }

  @override
  Future<void> pushGlobalProductsChanges() async {
    final globalProductsChanges =
        await _sync.getTableChanges('global_products');

    final inserts = <GlobalProductModel>[];
    final updates = <GlobalProductModel>[];
    final deletes = <String>[];

    for (final change in globalProductsChanges) {
      switch (change.operation) {
        case SyncOperation.delete:
          deletes.add(change.recordId);
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

    if (deletes.isNotEmpty) {
      await _remoteDatabase.deleteGlobalProducts(deletes);
    }

    await _sync.clearTablesChanges('global_products');
  }

  @override
  Future<void> pushStoreProductsChanges() async {
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
  }

  @override
  Future<void> syncAllProducts(String storeId) async {
    await pushGlobalProductsChanges();
    await pushStoreProductsChanges();

    final lastGlobalSync = await _sync.getLastSynced('global_products');
    final lastStoreProductsSync = await _sync.getLastSynced('store_products');

    final globalProducts =
        await _remoteDatabase.fetchGlobalProducts(lastSynced: lastGlobalSync);

    await _localDatabase.setGlobalProducts(globalProducts);

    final storeProducts = await _remoteDatabase.fetchStoreProducts(
      storeId: storeId,
      lastSynced: lastStoreProductsSync,
    );

    await _localDatabase.setStoreProducts(storeProducts.values.toList());

    final newDate = DateTime.now().toUtc();
    final newLastGlobalSync =
        SyncStateModel(tableName: 'global_products', lastSynced: newDate);
    final newLastStoreProductsSync =
        SyncStateModel(tableName: 'store_products', lastSynced: newDate);

    await _sync.saveLastSynced(newLastGlobalSync);
    await _sync.saveLastSynced(newLastStoreProductsSync);
  }
}
