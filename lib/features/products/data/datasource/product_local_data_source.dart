import '../../../../core/constants/log.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store_product.dart';
import '../models/global_product_model.dart';
import '../models/store_product_model.dart';

abstract class ProductLocalDataSource {
  Future<Result<List<Category>>> getAllCategories();
  Future<List<Map<String, dynamic>>> getGlobalProducts();
  Future<void> saveAllCategories(List<Category> categories);
  Future<void> saveGlobalProducts(List<GlobalProductModel> products);
  Future<Result<List<StoreProduct>>> getAllProducts(String storeId);
  Future<Result<StoreProduct>> getProductById(String storeProductId);
  Future<Result<Product?>> getProductByBarcode({
    required String barcode,
    required String storeId,
  });
  Future<bool> isBarcodeExists(String barcode);
  Future<Result<List<StoreProduct>>> searchProducts({
    required String query,
    required String storeId,
  });

  Future<Result<List<StoreProduct>>> getExpiredProducts(
    String storeId,
  );
  Future<Result<List<StoreProduct>>> getNearExpiryProducts(
    String storeId,
    int days,
  );
  Future<Result<void>> addProduct(StoreProduct product);
  Future<Result<void>> updateProduct(StoreProduct product);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl(this.db);
  final LocalDatabaseService db;

  /// sp  -> store_products,
  /// gb  -> global_produucts,
  /// c   -> category
  String _storeProductColumnsAndJoins([String joinType = 'LEFT']) => '''
          sp.id             AS store_product_id,
          sp.store_id       AS store_id,
          sp.product_id     AS product_id,
          sp.price          AS price,
          sp.quantity       AS quantity,
          sp.currency       AS currency,
          sp.expiry_date    AS expiry_date,
          sp.notes          AS notes,
          sp.updated_at     AS store_updated_at,

          gp.id             AS global_product_id,
          gp.name           AS product_name,
          gp.barcode        AS barcode,
          gp.created_at     AS product_created_at

        FROM store_products sp
        $joinType JOIN global_products gp ON sp.product_id = gp.id
        LEFT JOIN categories c ON gp.category_id = c.category_id
  ''';

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    try {
      final maps = await db.readRows(table: 'categories');
      final categories = maps.map(Category.fromLocal).toList();
      return SuccessState(categories);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<StoreProduct>>> getAllProducts(String storeId) async {
    try {
      final maps = await db.rawQuery(
        query: '''
        SELECT ${_storeProductColumnsAndJoins()}
        WHERE sp.store_id = ?
       ''',
        arguments: [storeId],
      );
      final products = maps.map(SellerProductModel.fromRemote).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<StoreProduct>> getProductById(String storeProductId) async {
    try {
      final response = await db.rawQuery(
        query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.id = ?
          LIMIT 1
        ''',
        arguments: [storeProductId],
      );
      final map = response.first;
      final product = SellerProductModel.fromRemote(map);
      return SuccessState(product);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<Product?>> getProductByBarcode({
    required String barcode,
    required String storeId,
  }) async {
    try {
      if (!await isBarcodeExists(barcode)) return const SuccessState(null);

      final response = await db.rawQuery(
        query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE gp.barcode = ? 
          AND sp.store_id = ? 
          LIMIT 1
        ''',
        arguments: [barcode, storeId],
      );

      final map = response.firstOrNull;

      if (map != null) {
        final storeProduct = SellerProductModel.fromLocal(map);
        return SuccessState(storeProduct);
      }

      final globalMap = await _getGlobalProductByBarcode(barcode);
      final globalProduct = GlobalProductModel.fromLocal(globalMap!);
      return SuccessState(globalProduct);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  Future<Map<String, dynamic>?> _getGlobalProductByBarcode(
    String barcode,
  ) async {
    final response = await db.rawQuery(
      query: '''
          SELECT ${_storeProductColumnsAndJoins('RIGHT')}
          WHERE gb.barcode = ?
          LIMIT 1
        ''',
      arguments: [barcode],
    );

    return response.firstOrNull;
  }

  @override
  Future<bool> isBarcodeExists(String barcode) async {
    final maps = await db.readWhereArguments(
      table: 'global_products',
      where: 'barcode',
      whereArgs: [barcode],
    );

    return maps.isNotEmpty;
  }

  @override
  Future<Result<List<StoreProduct>>> searchProducts({
    required String query,
    required String storeId,
  }) async {
    try {
      final maps = await db.rawQuery(
        query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.id = ? 
          AND LOWER(sp.name) LIKE LOWER(?)
        ''',
        arguments: [storeId, '%$query%'],
      );

      final products = maps.map(SellerProductModel.fromLocal).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<StoreProduct>>> getExpiredProducts(
    String storeId,
  ) async {
    try {
      final today = DateTime.now().toIso8601String();
      final maps = await db.rawQuery(
        query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.id = ?
          AND DATE(sp.expiry_date) <= DATE(?) 
        ''',
        arguments: [storeId, today],
      );

      final products = maps.map(SellerProductModel.fromLocal).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<StoreProduct>>> getNearExpiryProducts(
    String storeId,
    int days,
  ) async {
    try {
      final now = DateTime.now();
      final near = now.add(Duration(days: days)).toIso8601String();
      final maps = await db.rawQuery(
        query: '''
          SELECT ${_storeProductColumnsAndJoins()}
          WHERE sp.id = ?
          AND DATE(sp.expiry_date) BETWEEN DATE(?) AND DATE(?) 
        ''',
        arguments: [storeId, now.toIso8601String(), near],
      );

      final products = maps.map(SellerProductModel.fromLocal).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<void>> addProduct(StoreProduct product) async {
    try {
      if (!await isBarcodeExists(product.globalProduct.barcode ?? '')) {
        final globalProductModel =
            GlobalProductModel.fromEntity(product.globalProduct);
        await db.insertRow(
          table: 'global_products',
          map: globalProductModel.toMap(),
        );
      }

      final storeProductModel = SellerProductModel.fromEntity(product);

      await db.insertRow(
        table: 'store_products',
        map: storeProductModel.toMap(),
      );

      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<void>> updateProduct(StoreProduct product) async {
    try {
      await db.update(
        table: 'store_products',
        updated: SellerProductModel.fromEntity(product).toMap(),
        column: 'id',
        id: product.id,
      );

      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<void> saveAllCategories(List<Category> categories) async {
    final rows = categories.map((c) => c.toMap()).toList();
    await db.insertRows(rows: rows, table: 'categories');
  }

  @override
  Future<void> saveGlobalProducts(List<GlobalProductModel> products) async {
    final rows = products.map((p) => p.toMap()).toList();
    await db.insertRows(rows: rows, table: 'global_products');
  }

  @override
  Future<List<Map<String, dynamic>>> getGlobalProducts() async {
    try {
      final result = await db.rawQuery(
        query: '''
      gp.id             AS global_product_id,
      gp.name           AS product_name,
      gp.barcode        AS barcode,
      gp.created_at     AS product_created_at,

    FROM global_products gp 
    LEFT JOIN categories c ON gp.category_id = c.category_id
  ''',
      );

      return result;
    } catch (e) {
      Logger.debugLog(error: e);
      return [];
    }
  }
}
