import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/database/local/query_where_builder.dart';
import '../../../../core/shared/data/models/sync_change_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../models/global_product_model.dart';

abstract class GlobalProductLocalDataSource {
  Future<List<GlobalProductModel>> fetchGlobalProducts({
    bool includeDeleted = true,
  });

  Future<GlobalProductModel?> fetchGlobalProductById(String productId);

  Future<GlobalProductModel?> getGlobalProductByBarcode(String barcode);

  Future<GlobalProductModel> addGlobalProduct(
    GlobalProductModel product, [
    bool skipLocalTracking = false,
  ]);

  Future<void> updateGlobalProduct({
    required GlobalProductModel product,
    bool skipLocalTracking = false,
    Transaction? transaction,
  });

  Future<void> setGlobalProducts(List<GlobalProductModel> products);
}

class GlobalProductLocalDataSourceImpl implements GlobalProductLocalDataSource {
  GlobalProductLocalDataSourceImpl(this._db, this._sync);
  final LocalDatabaseService _db;
  final SyncLocalDataSource _sync;

  @override
  Future<List<GlobalProductModel>> fetchGlobalProducts({
    bool includeDeleted = true,
  }) async {
    final queryDeleted = includeDeleted ? '' : 'WHERE gp.is_deleted = 0';
    final rows = await _db.rawQuery(
      query: '''
    SELECT
      gp.id             AS global_product_id,
      gp.name           AS product_name,
      gp.barcode        AS barcode,
      gp.created_at     AS product_created_at,
      gp.updated_at     AS product_updated_at

    FROM global_products gp 
    LEFT JOIN categories c 
    ON gp.category_id = c.category_id
    $queryDeleted
  ''',
    );

    return rows.map(GlobalProductModel.fromLocal).toList();
  }

  @override
  Future<GlobalProductModel?> fetchGlobalProductById(String productId) async {
    final response = await _db.rawQuery(
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
    if (barcode.trim().isEmpty) return null;
    try {
      final response = await _db.rawQuery(
        query: '''
        SELECT 
          gp.id             AS global_product_id,
          gp.name           AS product_name,
          gp.barcode        AS barcode,
          gp.created_at     AS product_created_at,
          gp.updated_at     AS product_updated_at,

          c.category_id     AS category_id,
          c.category_name   AS category_name,
          c.updated_at      AS category_updated_at

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
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<GlobalProductModel> addGlobalProduct(
    GlobalProductModel product, [
    bool skipLocalTracking = false,
  ]) async {
    await _db.insertRow(map: product.toMap(), table: 'global_products');

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
  Future<void> updateGlobalProduct({
    required GlobalProductModel product,
    bool skipLocalTracking = false,
    Transaction? transaction,
  }) async {
    final updated = product.toMap();
    updated.remove('id');

    if (transaction != null) {
      await transaction.update(
        'global_products',
        updated,
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } else {
      await _db.update(
        updated: updated,
        whereParams: WhereQueryParams(
          groups: [
            FilterGroup(filters: [Filter(column: 'id', value: product.id!)]),
          ],
        ),
        table: 'global_products',
      );
    }

    if (skipLocalTracking) return;

    final globalProductChange = SyncChangeModel(
      tableName: 'global_products',
      recordId: product.id!,
      operation: SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(globalProductChange, transaction);
  }

  @override
  Future<void> setGlobalProducts(
    List<GlobalProductModel> products,
  ) async {
    final batch = await _db.batch;
    for (final product in products) {
      batch.insert(
        'global_products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
