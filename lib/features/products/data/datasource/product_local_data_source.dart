import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/data/models/sync_change_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/store_product.dart';
import '../models/global_product_model.dart';
import '../models/store_product_key.dart';
import '../models/store_product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<Category>> getAllCategories();
  Future<List<GlobalProductModel>> getGlobalProducts({bool isDeleted = true});
  Future<void> saveAllCategories(List<Category> categories);
  Future<ModelsProductsByIdentifier> getStoreProducts({
    required String storeId,
    bool isDeleted = true,
  });
  Future<StoreProductModel?> getStoreProductById(StoreProductKey productKey);
  Future<GlobalProductModel?> getGlobalProductById(String productId);
  Future<GlobalProductModel?> getGlobalProductByBarcode(String barcode);
  Future<List<StoreProductModel>> searchProducts({
    required String query,
    required String storeId,
  });

  Future<List<StoreProductModel>> getExpiredProducts(
    String storeId,
  );
  Future<List<StoreProductModel>> getNearExpiryProducts(
    String storeId,
    int days,
  );
  Future<StoreProduct> addStoreProduct(
    StoreProductModel product, [
    bool isSync = false,
  ]);
  Future<GlobalProductModel> addGlobalProduct(
    GlobalProductModel product, [
    bool isSync = false,
  ]);
  Future<void> updateStoreProduct(
    StoreProductModel product, [
    bool isSync = false,
  ]);
  Future<void> updateGlobalProduct(
    GlobalProductModel product, [
    bool isSync = false,
  ]);

  Future<void> setGlobalProducts(
    List<GlobalProductModel> products, [
    bool isSync = false,
  ]);

  Future<void> setStoreProducts(
    List<StoreProductModel> products, [
    bool isSync = false,
  ]);
  Future<void> deleteStoreProduct(
    StoreProductModel product, [
    bool isSync = false,
  ]);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl(this.db, this._sync);
  final LocalDatabaseService db;
  final SyncLocalDataSource _sync;

  /// sp  -> store_products,
  /// gb  -> global_produucts,
  /// c   -> category
  String _storeProductColumnsAndJoins() => '''
          sp.store_id       AS store_id,
          sp.product_id     AS product_id,
          sp.price          AS price,
          sp.quantity       AS quantity,
          sp.currency       AS currency,
          sp.expiry_date    AS expiry_date,
          sp.notes          AS notes,
          sp.updated_at     AS updated_at,
          sp.is_deleted     AS is_deleted,

          gp.id             AS global_product_id,
          gp.name           AS product_name,
          gp.barcode        AS barcode,
          gp.created_at     AS product_created_at
          gp.updated_at     AS product_updated_at
          gp.is_deleted     AS product_is_deleted

        FROM store_products sp
        LEFT JOIN global_products gp ON sp.product_id = gp.id
        LEFT JOIN categories c ON gp.category_id = c.category_id
  ''';

  @override
  Future<List<Category>> getAllCategories() async {
    final maps = await db.readRows(table: 'categories');
    return maps.map(Category.fromLocal).toList();
  }

  @override
  Future<ModelsProductsByIdentifier> getStoreProducts({
    required String storeId,
    bool isDeleted = true,
  }) async {
    final response = await db.rawQuery(
      query: '''
        SELECT ${_storeProductColumnsAndJoins()}
        WHERE sp.store_id = ? AND is_deleted = ? 
       ''',
      arguments: [storeId, isDeleted.toInt],
    );
    final products = <String, StoreProductModel>{};

    for (final m in response) {
      final product = StoreProductModel.fromRemote(m);
      final key = product.globalProduct.barcode ?? product.globalProduct.id!;
      products[key] = product;
    }

    return products;
  }


  @override
  Future<List<GlobalProductModel>> getGlobalProducts({
    bool isDeleted = true,
  }) async {
    final rows = await db.rawQuery(
      query: '''
      gp.id             AS global_product_id,
      gp.name           AS product_name,
      gp.barcode        AS barcode,
      gp.created_at     AS product_created_at,
      gp.updated_at     AS product_updated_at,

    FROM global_products gp 
    LEFT JOIN categories c ON gp.category_id = c.category_id
  ''',
    );

    return rows.map(GlobalProductModel.fromRemote).toList();
  }


  @override
  Future<GlobalProductModel?> getGlobalProductByBarcode(String barcode) async {
    try {
      final response = await db.rawQuery(
        query: '''
        SELECT 
          gp.id             AS global_product_id,
          gp.name           AS product_name,
          gp.barcode        AS barcode,
          gp.created_at     AS product_created_at
          gp.updated_at     AS product_updated_at

        FROM global_products gp
        LEFT JOIN categories c ON gp.category_id = c.category_id

        WHERE gp.barcode = ?
        LIMIT 1
        ''',
        arguments: [barcode],
      );

      final globalMap = response.first;
      final globalProduct = GlobalProductModel.fromLocal(globalMap);
      return globalProduct;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<StoreProductModel>> searchProducts({
    required String query,
    required String storeId,
  }) async {
    final maps = await db.rawQuery(
      query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.store_id = ? 
          AND LOWER(gp.name) LIKE LOWER(?)
        ''',
      arguments: [storeId, '%$query%'],
    );

    return maps.map(StoreProductModel.fromLocal).toList();
  }

  @override
  Future<List<StoreProductModel>> getExpiredProducts(
    String storeId,
  ) async {
    final today = DateTime.now().toUtc().toIso8601String();
    final maps = await db.rawQuery(
      query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.store_id = ?
          AND DATE(sp.expiry_date) <= DATE(?) 
        ''',
      arguments: [storeId, today],
    );

    return maps.map(StoreProductModel.fromLocal).toList();
  }

  @override
  Future<List<StoreProductModel>> getNearExpiryProducts(
    String storeId,
    int days,
  ) async {
    final now = DateTime.now().toUtc();
    final near = now.add(Duration(days: days)).toIso8601String();
    final maps = await db.rawQuery(
      query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.store_id = ?
          AND DATE(sp.expiry_date) BETWEEN DATE(?) AND DATE(?) 
        ''',
      arguments: [storeId, now.toIso8601String(), near],
    );

    return maps.map(StoreProductModel.fromLocal).toList();
  }

  @override
  Future<StoreProductModel> addStoreProduct(
    StoreProductModel product, [
    bool isSync = false,
  ]) async {
    bool isAddedToGlobal = false;
    await db.transaction((txn) async {
      final globalProductModel =
          GlobalProductModel.fromEntity(product.globalProduct);

      final id = await txn.insert(
        'global_products',
        globalProductModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      isAddedToGlobal = id != 0;

      await txn.insert(
        'store_products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });

    if (isSync) return product;

    final globalProductChange = SyncChangeModel(
      tableName: 'global_products',
      recordId: product.globalProduct.id!,
      operation: SyncOperation.insert,
      updatedAt: DateTime.now().toUtc(),
    );

    if (isAddedToGlobal) await _sync.addChange(globalProductChange);

    final storeProductKey = StoreProductKey(
      storeId: product.storeId,
      productId: product.globalProduct.id!,
    );
    final storeProductChange = SyncChangeModel(
      tableName: 'store_products',
      recordId: storeProductKey.toJson(),
      operation: SyncOperation.insert,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(storeProductChange);
    return product;
  }

  @override
  Future<void> updateStoreProduct(
    StoreProductModel product, [
    bool isSync = false,
  ]) async {
    final updated = product.toMap();
    final filterWhere = {
      'store_id': product.storeId,
      'product_id': product.globalProduct.id,
    };

    await db.update(
      updated: updated,
      filterWhere: filterWhere,
      table: 'store_products',
    );

    if (isSync) return;

    final storeProductKey = StoreProductKey(
      storeId: product.storeId,
      productId: product.globalProduct.id!,
    );

    final storeProductChange = SyncChangeModel(
      tableName: 'store_products',
      recordId: storeProductKey.toJson(),
      operation: SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(storeProductChange);
  }

  @override
  Future<void> updateGlobalProduct(
    GlobalProductModel product, [
    bool isSync = false,
  ]) async {
    final updated = product.toMap();
    final filterWhere = {
      'id': product.id,
    };

    await db.update(
      updated: updated,
      filterWhere: filterWhere,
      table: 'global_products',
    );

    if (isSync) return;

    final globalProductChange = SyncChangeModel(
      tableName: 'global_products',
      recordId: product.id!,
      operation: SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(globalProductChange);
  }

  @override
  Future<void> saveAllCategories(List<Category> categories) async {
    final rows = categories.map((c) => c.toMap()).toList();
    await db.insertRows(rows: rows, table: 'categories');
  }

  @override
  Future<void> setGlobalProducts(
    List<GlobalProductModel> products, [
    bool isSync = false,
  ]) async {
    for (final product in products) {
      final isFound = (await getGlobalProductById(product.id!)) != null;

      if (isFound) {
        await updateGlobalProduct(product, isSync);
      } else {
        await addGlobalProduct(product, isSync);
      }
    }
  }

  @override
  Future<void> setStoreProducts(
    List<StoreProductModel> products, [
    bool isSync = false,
  ]) async {
    for (final product in products) {
      final productKey = StoreProductKey(
        storeId: product.storeId,
        productId: product.globalProduct.id!,
      );
      final isFound = (await getStoreProductById(productKey)) != null;

      if (isFound) {
        await updateStoreProduct(product, isSync);
      } else {
        await updateStoreProduct(product, isSync);
      }
    }
  }

  @override
  Future<void> deleteStoreProduct(
    StoreProductModel product, [
    bool isSync = false,
  ]) async {
    await db.update(
      updated: {'is_deleted': true, 'updated_at': DateTime.now().toUtc()},
      filterWhere: {
        'store_id': product.storeId,
        'product_id': product.globalProduct.id,
      },
      table: 'store_products',
    );

    if (isSync) return;

    final storeProductKey = StoreProductKey(
      storeId: product.storeId,
      productId: product.globalProduct.id!,
    );

    final change = SyncChangeModel(
      tableName: 'store_products',
      recordId: storeProductKey.toJson(),
      operation: SyncOperation.delete,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }

  @override
  Future<StoreProductModel?> getStoreProductById(
    StoreProductKey productKey,
  ) async {
    final response = await db.rawQuery(
      query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.store_id = ? AND sp.product_id = ?
          LIMIT 1
        ''',
      arguments: [productKey.storeId, productKey.productId],
    );
    if (response.isEmpty) return null;
    final map = response.first;
    return StoreProductModel.fromRemote(map);
  }

  @override
  Future<GlobalProductModel?> getGlobalProductById(String productId) async {
    final response = await db.rawQuery(
      query: '''
        SELECT 
          gp.id             AS global_product_id,
          gp.name           AS product_name,
          gp.barcode        AS barcode,
          gp.created_at     AS product_created_at
          gp.updated_at     AS product_updated_at
        FROM global_products as gp
        where gp.id = ?
''',
      arguments: [productId],
    );

    if (response.isEmpty) return null;

    return GlobalProductModel.fromLocal(response.first);
  }

  @override
  Future<GlobalProductModel> addGlobalProduct(
    GlobalProductModel product, [
    bool isSync = false,
  ]) async {
    await db.insertRow(map: product.toMap(), table: 'global_products');

    if (isSync) return product;

    final globalProductChange = SyncChangeModel(
      tableName: 'global_products',
      recordId: product.id!,
      operation: SyncOperation.insert,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(globalProductChange);

    return product;
  }
}
