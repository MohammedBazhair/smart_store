import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/database/local/query_where_builder.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/data/models/sync_change_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../models/global_product_model.dart';
import '../models/store_product_key.dart';
import '../models/store_product_model.dart';

abstract class ProductLocalDataSource {
  Future<Category?> fetchCategory(int categoryId);
  Future<List<Category>> fetchAllCategories();
  Future<void> setAllCategories(List<Category> categories);

  Future<List<GlobalProductModel>> fetchGlobalProducts({
    bool includeDeleted = true,
  });
  Future<GlobalProductModel?> fetchGlobalProductById(String productId);
  Future<GlobalProductModel?> getGlobalProductByBarcode(String barcode);

  Future<ModelsProductsByIdentifier> fetchStoreProducts({
    required String storeId,
    bool includeDeleted = true,
    bool onlyWithoutBarcode = false,
  });

  Future<StoreProductModel?> fetchStoreProductById(StoreProductKey productKey);
  Future<List<StoreProductModel>> searchStoreProducts({
    required ProductQuery query,
    required String storeId,
  });
  Future<List<StoreProductModel>> fetchExpiredStoreProducts(String storeId);
  Future<List<StoreProductModel>> fetchNearExpiryStoreProducts(
    String storeId,
    int days,
  );

  Future<GlobalProductModel> addGlobalProduct(
    GlobalProductModel product, [
    bool skipLocalTracking = false,
  ]);
  Future<StoreProduct> addStoreProduct(
    StoreProductModel product, [
    bool skipLocalTracking = false,
  ]);

  Future<void> updateGlobalProduct(
    GlobalProductModel product, [
    bool skipLocalTracking = false,
  ]);
  Future<void> updateStoreProduct(
    StoreProductModel product, [
    bool skipLocalTracking = false,
  ]);

  Future<void> setGlobalProducts(List<GlobalProductModel> products);
  Future<void> setStoreProducts(List<StoreProductModel> products);

  Future<void> deleteStoreProduct(
    StoreProductKey productKey, [
    bool skipLocalTracking = false,
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
          sp.expiry_date    AS expiry_date,
          sp.notes          AS notes,
          sp.updated_at     AS updated_at,
          sp.is_deleted     AS is_deleted,

          gp.id             AS global_product_id,
          gp.name           AS product_name,
          gp.category_id    AS category_id,
          gp.barcode        AS barcode,
          gp.created_at     AS product_created_at,
          gp.updated_at     AS product_updated_at,
          gp.is_deleted     AS product_is_deleted,

          c.category_id     AS category_id,
          c.category_name   AS category_name,
          c.updated_at      AS category_updated_at
        
        FROM store_products sp
        LEFT JOIN global_products gp ON sp.product_id = gp.id
        LEFT JOIN categories c ON gp.category_id = c.category_id
  ''';

  @override
  Future<List<Category>> fetchAllCategories() async {
    final maps = await db.rawQuery(
      query: '''
      SELECT c.category_id     AS category_id,
             c.category_name   AS category_name,
             c.updated_at      AS category_updated_at
      FROM categories c''',
    );

    return maps.map(Category.fromLocal).toList();
  }

  @override
  Future<void> setAllCategories(List<Category> categories) async {
    for (final category in categories) {
      final result = await fetchCategory(category.id);

      if (result == null) {
        await db.insertRow(map: category.toMap(), table: 'categories');
      } else {
        await db.update(
          updated: category.toMapUpdate(),
          whereParams: WhereQueryParams(
            groups: [
              FilterGroup(
                filters: [Filter(column: 'category_id', value: category.id)],
              ),
            ],
          ),
          table: 'categories',
        );
      }
    }
  }

  @override
  Future<List<GlobalProductModel>> fetchGlobalProducts({
    bool includeDeleted = true,
  }) async {
    final rows = await db.rawQuery(
      query: '''
    SELECT
      gp.id             AS global_product_id,
      gp.name           AS product_name,
      gp.barcode        AS barcode,
      gp.created_at     AS product_created_at,
      gp.updated_at     AS product_updated_at

    FROM global_products gp 
    LEFT JOIN categories c ON gp.category_id = c.category_id
    WHERE gp.is_deleted = ?
  ''',
      arguments: [includeDeleted.toInt],
    );

    return rows.map(GlobalProductModel.fromLocal).toList();
  }

  @override
  Future<GlobalProductModel?> fetchGlobalProductById(String productId) async {
    final response = await db.rawQuery(
      query: '''
        SELECT 
          gp.id             AS global_product_id,
          gp.name           AS product_name,
          gp.category_id    AS category_id,
          gp.barcode        AS barcode,
          gp.created_at     AS product_created_at,
          gp.updated_at     AS product_updated_at,
          gp.is_deleted     AS product_is_deleted,

          c.category_id     AS category_id,
          c.category_name   AS category_name,
          c.updated_at      AS category_updated_at

        FROM global_products as gp
        LEFT JOIN categories as c ON gp.category_id = c.category_id
        where gp.id = ?
''',
      arguments: [productId],
    );

    if (response.isEmpty) return null;

    return GlobalProductModel.fromLocal(response.first);
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
          gp.created_at     AS product_created_at,
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
  Future<ModelsProductsByIdentifier> fetchStoreProducts({
    required String storeId,
    bool includeDeleted = true,
    bool onlyWithoutBarcode = false,
  }) async {
    final  barcodeWhereQuery= onlyWithoutBarcode?   'AND gp.barcode IS NULL' : '';
    try {
      final response = await db.rawQuery(
        query: '''
    SELECT ${_storeProductColumnsAndJoins()}
    WHERE sp.store_id = ? AND sp.is_deleted = ? 
    $barcodeWhereQuery
    ORDER BY sp.expiry_date DESC
   ''',
        arguments: [storeId, includeDeleted.toInt],
      );
      final products = <String, StoreProductModel>{};

      for (final m in response) {
        final product = StoreProductModel.fromLocal(m);
        final key = product.globalProduct.barcode ?? product.globalProduct.id!;
        products[key] = product;
      }

      return products;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return {};
    }
  }

  @override
  Future<StoreProductModel?> fetchStoreProductById(
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
    return StoreProductModel.fromLocal(map);
  }

  @override
  Future<List<StoreProductModel>> searchStoreProducts({
    required ProductQuery query,
    required String storeId,
  }) async {
    final queryRaw = StringBuffer('''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.store_id = ? 
          AND sp.is_deleted = 0
        ''');

    if (query.hasCategory) queryRaw.write(' AND c.category_id = ?');
    if (query.isSearching) queryRaw.write(' AND LOWER(gp.name) LIKE LOWER(?)');
    switch (query.sortType) {
      case ProductSortType.quantityAsc:
        queryRaw.write(' ORDER BY sp.quantity ASC');
        break;
      case ProductSortType.quantityDesc:
        queryRaw.write(' ORDER BY sp.quantity DESC');
        break;
      case ProductSortType.expiryAsc:
        queryRaw.write(' ORDER BY sp.expiry_date ASC');
        break;
      case ProductSortType.expiryDesc:
        queryRaw.write(' ORDER BY sp.expiry_date DESC');
        break;
    }
   
   
    final maps = await db.rawQuery(
      query: queryRaw.toString(),
      arguments: [
        storeId,
        if (query.hasCategory) query.category?.id,
        if (query.isSearching) '%${query.search}%',
      ],
    );

    return maps.map(StoreProductModel.fromLocal).toList();
  }

  @override
  Future<List<StoreProductModel>> fetchExpiredStoreProducts(
    String storeId,
  ) async {
    final today = DateTime.now().toUtc().toIso8601String();
    final maps = await db.rawQuery(
      query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.store_id = ?
          AND DATE(sp.expiry_date) <= DATE(?) 
          AND sp.is_deleted = ?
        ''',
      arguments: [storeId, today, false.toInt],
    );

    return maps.map(StoreProductModel.fromLocal).toList();
  }

  @override
  Future<List<StoreProductModel>> fetchNearExpiryStoreProducts(
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
          AND sp.is_deleted = ?
        ''',
      arguments: [storeId, now.toIso8601String(), near, false.toInt],
    );

    return maps.map(StoreProductModel.fromLocal).toList();
  }

  @override
  Future<GlobalProductModel> addGlobalProduct(
    GlobalProductModel product, [
    bool skipLocalTracking = false,
  ]) async {
    await db.insertRow(map: product.toMap(), table: 'global_products');

    if (skipLocalTracking) return product;

    final globalProductChange = SyncChangeModel(
      tableName: 'global_products',
      recordId: product.id!,
      operation: SyncOperation.insert,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(globalProductChange);

    return product;
  }

  @override
  Future<StoreProductModel> addStoreProduct(
    StoreProductModel product, [
    bool skipLocalTracking = false,
  ]) async {
    bool isAddedToGlobal = false;
    SyncOperation operation = SyncOperation.insert;
    final storeProductKey = StoreProductKey(
      storeId: product.storeId,
      productId: product.globalProduct.id!,
    );
    try {
      await db.transaction((txn) async {
        Future<bool> _isProductSoftDeleted(StoreProductKey key) async {
          final result = await txn.rawQuery(
            '''
    SELECT product_id FROM store_products WHERE store_id = ? AND product_id = ? AND is_deleted = ?
    ''',
            [key.storeId, key.productId, true.toInt],
          );
          return result.isNotEmpty;
        }

        final globalProductModel =
            GlobalProductModel.fromEntity(product.globalProduct);

        final id = await txn.insert(
          'global_products',
          globalProductModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        isAddedToGlobal = id != 0;

        if (await _isProductSoftDeleted(storeProductKey)) {
          operation = SyncOperation.update;
          await txn.update(
            'store_products',
            product.toMap()
              ..remove('store_id')
              ..remove('key'),
            where: 'store_id = ? AND product_id = ?',
            whereArgs: [storeProductKey.storeId, storeProductKey.productId],
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        } else {
          await txn.insert(
            'store_products',
            product.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      });
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }

    if (skipLocalTracking) return product;

    final globalProductChange = SyncChangeModel(
      tableName: 'global_products',
      recordId: product.globalProduct.id!,
      operation: SyncOperation.insert,
      updatedAt: DateTime.now().toUtc(),
    );

    if (isAddedToGlobal) await _sync.addChange(globalProductChange);

    final storeProductChange = SyncChangeModel(
      tableName: 'store_products',
      recordId: storeProductKey.toJson(),
      operation: operation,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(storeProductChange);
    return product;
  }

  @override
  Future<void> updateGlobalProduct(
    GlobalProductModel product, [
    bool skipLocalTracking = false,
  ]) async {
    final updated = product.toMap();
    updated.remove('id');

    await db.update(
      updated: updated,
      whereParams: WhereQueryParams(
        groups: [
          FilterGroup(filters: [Filter(column: 'id', value: product.id!)]),
        ],
      ),
      table: 'global_products',
    );

    if (skipLocalTracking) return;

    final globalProductChange = SyncChangeModel(
      tableName: 'global_products',
      recordId: product.id!,
      operation: SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(globalProductChange);
  }

  @override
  Future<void> updateStoreProduct(
    StoreProductModel product, [
    bool skipLocalTracking = false,
  ]) async {
    final updated = product.toMap();
    final whereParams = WhereQueryParams(
      groups: [
        FilterGroup(
          filters: [
            Filter(column: 'store_id', value: product.storeId),
            Filter(column: 'product_id', value: product.globalProduct.id!),
          ],
        ),
      ],
    );

    await db.update(
      updated: updated,
      whereParams: whereParams,
      table: 'store_products',
    );

    final globalProduct = GlobalProductModel.fromEntity(product.globalProduct);

    await updateGlobalProduct(globalProduct);

    if (skipLocalTracking) return;

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
  Future<void> setGlobalProducts(
    List<GlobalProductModel> products,
  ) async {
    final batch = db.batch;
    for (final product in products) {
      batch.insert(
        'global_products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> setStoreProducts(
    List<StoreProductModel> products,
  ) async {
    final batch = db.batch;
    for (final product in products) {
      batch.insert(
        'store_products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteStoreProduct(
    StoreProductKey productKey, [
    bool skipLocalTracking = false,
  ]) async {
    final whereParams = WhereQueryParams(
      groups: [
        FilterGroup(
          filters: [
            Filter(column: 'store_id', value: productKey.storeId),
            Filter(column: 'product_id', value: productKey.productId),
          ],
        ),
      ],
    );

    await db.update(
      updated: {
        'is_deleted': true.toInt,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      whereParams: whereParams,
      table: 'store_products',
    );

    if (skipLocalTracking) return;

    final change = SyncChangeModel(
      tableName: 'store_products',
      recordId: productKey.toJson(),
      operation: SyncOperation.delete,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }

  @override
  Future<Category?> fetchCategory(int categoryId) async {
    final rows = await db.query(
      table: 'categories',
      whereParams: WhereQueryParams(
        groups: [
          FilterGroup(
            filters: [Filter(column: 'category_id', value: categoryId)],
          ),
        ],
      ),
    );

    if (rows.isEmpty) return null;

    final category = Category.fromLocal(rows.first);
    return category;
  }
  

}
