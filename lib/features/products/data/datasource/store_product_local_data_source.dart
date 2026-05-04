import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/database/local/query_where_builder.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/data/models/sync_change_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../models/global_product_model.dart';
import '../models/store_product_key.dart';
import '../models/store_product_model.dart';
import '../product_query_builder.dart';

abstract class StoreProductLocalDataSource {
  Future<Map<String, StoreProductModel>> fetchStoreProducts({
    required String storeId,
    bool includeDeleted = true,
    bool onlyWithoutBarcode = false,
  });

  Future<StoreProductModel?> fetchStoreProductById(
    StoreProductKey productKey,
  );

  Future<StoreProductModel> addStoreProduct(
    StoreProductModel product, [
    bool skipLocalTracking = false,
  ]);

  Future<void> updateStoreProduct({
    required StoreProductModel product,
    bool skipLocalTracking = false,
    Transaction? transaction,
  });

  Future<void> setStoreProducts(List<StoreProductModel> products);

  Future<void> deleteStoreProduct(
    StoreProductKey productKey, [
    bool skipLocalTracking = false,
  ]);

  Future<List<StoreProductModel>> fetchExpiredStoreProducts(
    String storeId,
  );

  Future<List<StoreProductModel>> fetchNearExpiryStoreProducts(
    String storeId,
    int days,
  );
}

class StoreProductLocalDataSourceImpl implements StoreProductLocalDataSource {
  StoreProductLocalDataSourceImpl(this._db, this._sync);
  final LocalDatabaseService _db;
  final SyncLocalDataSource _sync;

  @override
  Future<ModelsProductsByIdentifier> fetchStoreProducts({
    required String storeId,
    bool includeDeleted = true,
    bool onlyWithoutBarcode = false,
  }) async {
    try {
      final deletedQuery = includeDeleted ? '' : 'AND sp.is_deleted = 0';
      final barcodeQuery = onlyWithoutBarcode ? 'AND gp.barcode IS NULL' : '';
      final query = '''
      SELECT ${ProductQueryBuilder.storeProductColumnsAndJoins}
      WHERE sp.store_id = ?
        $deletedQuery
        $barcodeQuery
      ORDER BY sp.expiry_date ASC NULLS LAST
    ''';

      final response = await _db.rawQuery(
        query: query,
        arguments: [storeId],
      );

      final products = <String, StoreProductModel>{};

      for (final m in response) {
        final product = StoreProductModel.fromLocal(m);

        final key = product.id!;
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
    final response = await _db.rawQuery(
      query: '''
          SELECT ${ProductQueryBuilder.storeProductColumnsAndJoins}
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
  Future<List<StoreProductModel>> fetchExpiredStoreProducts(
    String storeId,
  ) async {
    final today = DateTime.now().toUtc().toIso8601String();
    final maps = await _db.rawQuery(
      query: '''
          SELECT ${ProductQueryBuilder.storeProductColumnsAndJoins}
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
    final maps = await _db.rawQuery(
      query: '''
          SELECT ${ProductQueryBuilder.storeProductColumnsAndJoins}
          WHERE sp.store_id = ?
          AND DATE(sp.expiry_date) BETWEEN DATE(?) AND DATE(?) 
          AND sp.is_deleted = ?
        ''',
      arguments: [storeId, now.toIso8601String(), near, false.toInt],
    );

    return maps.map(StoreProductModel.fromLocal).toList();
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
      await _db.transaction((txn) async {
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
      rethrow;
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
  Future<void> updateStoreProduct({
    required StoreProductModel product,
    bool skipLocalTracking = false,
    Transaction? transaction,
  }) async {
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

    if (transaction != null) {
      await transaction.update(
        'store_products',
        updated,
        where: 'store_id = ? AND product_id = ?',
        whereArgs: [product.storeId, product.globalProduct.id],
      );
    } else {
      await _db.update(
        updated: updated,
        whereParams: whereParams,
        table: 'store_products',
      );
    }

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

    await _sync.addChange(storeProductChange, transaction);
  }

  @override
  Future<void> setStoreProducts(
    List<StoreProductModel> products,
  ) async {
    final batch = await _db.batch;
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

    await _db.update(
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
}
