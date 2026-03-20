import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/remote/remote_database_service.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/data/models/sync_state_model.dart';
import '../../domain/entities/category.dart';
import '../models/global_product_model.dart';
import '../models/store_product_key.dart';
import '../models/store_product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<Category>> fetchAllCategories();

  Future<List<GlobalProductModel>> fetchGlobalProducts({
    SyncStateModel? lastSynced,
    bool includeDeleted = true,
  });
  Future<GlobalProductModel?> fetchGlobalProductByBarcode(String barcode);
  Future<StoreProductModel> fetchStoreProductById(StoreProductKey productKey);
  Future<ModelsProductsByIdentifier> fetchStoreProducts({
    required String storeId,
    SyncStateModel? lastSynced,
    bool includeDeleted = true,
  });
  Future<List<StoreProductModel>> fetchExpiredStoreProducts(String storeId);
  Future<List<StoreProductModel>> fetchNearExpiryStoreProducts(
    String storeId,
    int days,
  );

  Future<void> addStoreProduct(StoreProductModel product);
  Future<void> addGlobalProducts(List<GlobalProductModel> products);
  Future<void> addStoreProducts(List<StoreProductModel> products);

  Future<void> updateGlobalProduct(GlobalProductModel product);
  Future<void> updateGlobalProducts(List<GlobalProductModel> products);
  Future<void> updateStoreProduct(StoreProductModel product);
  Future<void> updateStoreProducts(List<StoreProductModel> products);

  Future<void> deleteStoreProduct(StoreProductKey productKey);
  Future<void> deleteStoreProducts(List<StoreProductKey> productKeys);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);
  final RemoteDatabaseService _client;

  @override
  Future<List<Category>> fetchAllCategories() async {
    final response = await _client.readRows(table: 'categories');
    return response.map(Category.fromRemote).toList();
  }

  @override
  Future<List<GlobalProductModel>> fetchGlobalProducts({
    SyncStateModel? lastSynced,
    bool includeDeleted = true,
  }) async {
    final response = _client.client.from('global_products').select(
          '*, categories(*)',
        );

    final reponseResult = includeDeleted
        ? response
        : response.eq('is_deleted', includeDeleted.toInt);

    final lastDate = lastSynced?.lastSynced.toIso8601String();
    final results = lastDate != null
        ? reponseResult.gt('updated_at', lastDate)
        : reponseResult;
    final rows = await results;

    return rows.map(GlobalProductModel.fromRemote).toList();
  }

  @override
  Future<GlobalProductModel?> fetchGlobalProductByBarcode(
    String barcode,
  ) async {
    try {
      final response = await _client.client
          .from('global_products')
          .select('*, categories(*)')
          .eq('barcode', barcode);
      final globalProductMap = response.first;
      final globalProduct = GlobalProductModel.fromRemote(globalProductMap);
      return globalProduct;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<StoreProductModel> fetchStoreProductById(
    StoreProductKey productKey,
  ) async {
    final response = await _client.client
        .from('store_products')
        .select(
          '*, global_products(*, categories(*))',
        )
        .eq('store_id', productKey.storeId)
        .eq('product_id', productKey.productId);
    final map = response.first;
    return StoreProductModel.fromRemote(map);
  }

  @override
  Future<ModelsProductsByIdentifier> fetchStoreProducts({
    required String storeId,
    SyncStateModel? lastSynced,
    bool includeDeleted = true,
  }) async {
    final response = _client.client
        .from('store_products')
        .select(
          '*, global_products(*, categories(*))',
        )
        .eq('store_id', storeId);

    final reponseResult = includeDeleted
        ? response
        : response.eq('is_deleted', includeDeleted.toInt);

    final lastDate = lastSynced?.lastSynced.toIso8601String();
    final result = lastDate != null
        ? reponseResult.gt('updated_at', lastDate)
        : reponseResult;
    final rows = await result;
    final products = <String, StoreProductModel>{};

    for (final m in rows) {
      final product = StoreProductModel.fromRemote(m);
      final key = product.globalProduct.barcode ?? product.globalProduct.id!;
      products[key] = product;
    }
    return products;
  }

  @override
  Future<List<StoreProductModel>> fetchExpiredStoreProducts(
    String storeId,
  ) async {
    final today = DateTime.now().toUtc().toIso8601String();
    final response = await _client.client
        .from('store_products')
        .select(
          '*, global_products(*, categories(*))',
        )
        .eq('store_id', storeId)
        .eq('is_deleted', false.toInt)
        .lte('expiry_date', today);

    return response.map(StoreProductModel.fromRemote).toList();
  }

  @override
  Future<List<StoreProductModel>> fetchNearExpiryStoreProducts(
    String storeId,
    int days,
  ) async {
    final now = DateTime.now().toUtc();
    final near = now.add(Duration(days: days));
    final response = await _client.client
        .from('store_products')
        .select(
          '*, global_products(*, categories(*))',
        )
        .eq('store_id', storeId)
        .eq('is_deleted', false.toInt)
        .gte('expiry_date', now.toIso8601String())
        .lte('expiry_date', near.toIso8601String());

    return response.map(StoreProductModel.fromRemote).toList();
  }

  Future<bool> _isProductSoftDeleted(StoreProductKey key) async {
    final result = await _client.readRowsWhere(
      table: 'store_products',
      filters: {...key.toMap(), 'is_deleted': true.toInt},
    );

    return result.firstOrNull?.isEmpty ?? false;
  }

  @override
  Future<StoreProductModel> addStoreProduct(
    StoreProductModel product,
  ) async {
    final globalModel = GlobalProductModel.fromEntity(product.globalProduct);
    await _client.upsertRow(
      table: 'global_products',
      row: globalModel.toMap(),
      onConflict: 'id',
    );

    final key = StoreProductKey(
      storeId: product.storeId,
      productId: product.globalProduct.id!,
    );

    if (await _isProductSoftDeleted(key)) {
      await _client.update(
        updated: product.toMap()
          ..remove('product_id')
          ..remove('store_id'),
        whereFilter: key.toMap(),
        table: 'store_products',
      );
    } else {
      await _client.insertRow(
        map: product.toMap(),
        table: 'store_products',
      );
    }

    return product;
  }

  @override
  Future<void> addGlobalProducts(List<GlobalProductModel> products) async {
    try {
      Logger.debugLog(message: products.toString());
      final rows = products.map((m) => m.toMap()).toList();
      Logger.debugLog(message: 'rows:');
      Logger.debugLog(message: rows.toString());

      await _client.insertRows(rows: rows, table: 'global_products');
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  @override
  Future<void> addStoreProducts(List<StoreProductModel> products) async {
    final rows = products.map((m) => m.toMap()).toList();
    await _client.insertRows(rows: rows, table: 'store_products');
  }

  @override
  Future<void> updateGlobalProduct(GlobalProductModel product) async {
    final updated = product.toMap();
    updated.remove('id');
    await _client.update(
      updated: updated,
      table: 'global_products',
      whereFilter: {'id': product.id!},
    );
  }

  @override
  Future<void> updateGlobalProducts(List<GlobalProductModel> products) async {
    final rows = products.map((m) => m.toMap()).toList();
    await _client.updateRows(
      rows: rows,
      table: 'global_products',
      onConflict: 'id',
    );
  }

  @override
  Future<void> updateStoreProduct(
    StoreProductModel product,
  ) async {
    final map = product.toMap();
    await _client.update(
      updated: map,
      table: 'store_products',
      whereFilter: {
        'product_id': product.globalProduct.id!,
        'store_id': product.storeId,
      },
    );

    final globalProduct = GlobalProductModel.fromEntity(product.globalProduct);
    await updateGlobalProduct(globalProduct);
  }

  @override
  Future<void> updateStoreProducts(List<StoreProductModel> products) async {
    final rows = products.map((m) => m.toMap()).toList();
    await _client.updateRows(
      rows: rows,
      table: 'store_products',
      onConflict: 'store_id, product_id',
    );
  }

  @override
  Future<void> deleteStoreProduct(StoreProductKey productKey) {
    return _client.update(
      updated: {
        'is_deleted': true.toInt,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      whereFilter: productKey.toMap(),
      table: 'store_products',
    );
  }

  @override
  Future<void> deleteStoreProducts(List<StoreProductKey> productKeys) async {
    if (productKeys.isEmpty) return;

    final grouped = <String, List<String>>{};

    for (final key in productKeys) {
      grouped.update(
        key.storeId,
        (value) => value..add(key.productId),
        ifAbsent: () => [key.productId],
      );
    }

    final futures = grouped.entries.map((entry) {
      return _client.client
          .from('store_products')
          .update({
            'is_deleted': true.toInt,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('store_id', entry.key)
          .inFilter('product_id', entry.value);
    });

    await Future.wait(futures);
  }
}
