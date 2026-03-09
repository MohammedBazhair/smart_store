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
  Future<List<Category>> getAllCategories();
  Future<List<GlobalProductModel>> getGlobalProducts({
    SyncStateModel? lastSync,
    bool isDeleted = true,
  });
  Future<ModelsProductsByIdentifier> getStoreProducts({
    required String storeId,
    SyncStateModel? lastSync,
    bool isDeleted = true,
  });
  Future<StoreProductModel> getProductById(StoreProductKey productKey);
  Future<GlobalProductModel?> getGlobalProductByBarcode(String barcode);
  Future<List<StoreProductModel>> getExpiredProducts(
    String storeId,
  );
  Future<List<StoreProductModel>> getNearExpiryProducts(
    String storeId,
    int days,
  );
  Future<void> insertStoreProducts(List<StoreProductModel> products);
  Future<void> updateStoreProductss(List<StoreProductModel> products);
  Future<void> deleteStoreProducts(List<StoreProductKey> productKeys);

  Future<void> deleteStoreProduct(StoreProductKey productKey);

  Future<void> insertGlobalProducts(List<GlobalProductModel> products);
  Future<void> updateGlobalProducts(List<GlobalProductModel> products);
  Future<void> addProduct(StoreProductModel product);
  Future<void> updateStoreProduct(StoreProductModel product);
  Future<void> updateGlobalProduct(GlobalProductModel product);

  Future<void> deleteGlobalProducts(List<String> productsIds);
  Future<void> deleteGlobalProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);
  final RemoteDatabaseService _client;

  @override
  Future<List<Category>> getAllCategories() async {
    final response = await _client.readRows(table: 'categories');
    return response.map(Category.fromRemote).toList();
  }

  @override
  Future<ModelsProductsByIdentifier> getStoreProducts({
    required String storeId,
    SyncStateModel? lastSync,
    bool isDeleted = true,
  }) async {
    final response = _client.client
        .from('store_products')
        .select(
          '*, global_products(*, categories(*))',
        )
        .eq('store_id', storeId)
        .eq('is_deleted', isDeleted.toInt);

    final lastDate = lastSync?.lastSync.toIso8601String();
    final result =
        lastDate != null ? response.gt('updated_at', lastDate) : response;
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
  Future<List<GlobalProductModel>> getGlobalProducts({
    SyncStateModel? lastSync,
    bool isDeleted = true,
  }) async {
    final response = _client.client
        .from('global_products')
        .select(
          '*, categories(*)',
        )
        .eq('is_deleted', isDeleted.toInt);

    final lastDate = lastSync?.lastSync.toIso8601String();
    final results =
        lastDate != null ? response.gt('updated_at', lastDate) : response;
    final rows = await results;

    return rows.map(GlobalProductModel.fromRemote).toList();
  }

  @override
  Future<StoreProductModel> getProductById(StoreProductKey productKey) async {
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
  Future<GlobalProductModel?> getGlobalProductByBarcode(
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
    } catch (e) {
      Logger.debugLog(error: e);
      return null;
    }
  }

  @override
  Future<List<StoreProductModel>> getExpiredProducts(
    String storeId,
  ) async {
    final today = DateTime.now().toUtc().toIso8601String();
    final response = await _client.client
        .from('store_products')
        .select(
          '*, global_products(*, categories(*))',
        )
        .eq('store_id', storeId)
        .lte('expiry_date', today);

    return response.map(StoreProductModel.fromRemote).toList();
  }

  @override
  Future<List<StoreProductModel>> getNearExpiryProducts(
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
        .gte('expiry_date', now.toIso8601String())
        .lte('expiry_date', near.toIso8601String());

    return response.map(StoreProductModel.fromRemote).toList();
  }

  @override
  Future<StoreProductModel> addProduct(
    StoreProductModel product,
  ) async {
    final globalProduct =
        await getGlobalProductByBarcode(product.globalProduct.barcode ?? '');

    if (globalProduct == null) {
      final globalProductMap =
          GlobalProductModel.fromEntity(product.globalProduct).toMap();
      await _client.insertRow(
        map: globalProductMap,
        table: 'global_products',
      );
    }
    final storeProductMap = StoreProductModel.fromEntity(product).toMap();

    await _client.insertRow(
      map: storeProductMap,
      table: 'store_products',
    );

    return product;
  }

  @override
  Future<void> updateStoreProduct(
    StoreProductModel product,
  ) async {
    final map = StoreProductModel.fromEntity(product).toMap();
    await _client.client
        .from('store_products')
        .update(map)
        .eq('product_id', product.globalProduct.id!)
        .eq('store_id', product.storeId);
  }

  @override
  Future<void> updateGlobalProduct(GlobalProductModel product) async {
    await _client.update(
      updated: product.toMap(),
      table: 'global_products',
      whereFilter: {'id': product.id!},
    );
  }

  @override
  Future<void> insertGlobalProducts(List<GlobalProductModel> products) async {
    final rows = products.map((m) => m.toMap()).toList();
    await _client.insertRows(rows: rows, table: 'global_products');
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
  Future<void> deleteGlobalProduct(String productId) {
    return _client.delete(
      id: productId,
      column: 'id',
      table: 'global_products',
    );
  }

  @override
  Future<void> deleteGlobalProducts(List<String> productsIds) async {
    final futures = productsIds.map(deleteGlobalProduct);

    await Future.wait(futures);
  }

  @override
  Future<void> deleteStoreProduct(StoreProductKey productKey) {
    return _client.deleteWhere(
      filters: productKey.toMap(),
      table: 'store_products',
    );
  }

  @override
  Future<void> deleteStoreProducts(List<StoreProductKey> productKeys) async {
    final futures = productKeys.map(deleteStoreProduct);

    await Future.wait(futures);
  }

  @override
  Future<void> insertStoreProducts(List<StoreProductModel> products) async {
    final rows = products.map((m) => m.toMap()).toList();
    await _client.insertRows(rows: rows, table: 'store_products');
  }

  @override
  Future<void> updateStoreProductss(List<StoreProductModel> products) async {
    final rows = products.map((m) => m.toMap()).toList();
    await _client.updateRows(
      rows: rows,
      table: 'store_products',
      onConflict: 'store_id, product_id',
    );
  }
}
