import '../../../../core/database/local/local_database_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/seller_product.dart';
import '../models/global_product_model.dart';
import '../models/seller_product_model.dart';

abstract class ProductLocalDataSource {
  Future<Result<List<Category>>> getAllCategories();
  Future<Result<List<SellerProduct>>> getAllProducts(String sellerId);
  Future<Result<SellerProduct>> getProductById(String sellerProductId);
  Future<Result<Product?>> getProductByBarcode({
    required String barcode,
    required String sellerId,
  });
  Future<bool> isBarcodeExists(String barcode);
  Future<Result<List<SellerProduct>>> searchProducts({
    required String query,
    required String sellerId,
  });

  Future<Result<List<SellerProduct>>> getExpiredProducts(
    String sellerId,
  );
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(
    String sellerId,
    int days,
  );
  Future<Result<void>> addProduct(SellerProduct product);
  Future<Result<void>> updateProduct(SellerProduct product);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl(this.db);
  final LocalDatabaseService db;

  /// sp  -> seller_products,
  /// gb  -> global_produucts,
  /// c   -> category
  String _sellerProductColumnsAndJoins([String joinType = 'LEFT']) => '''
          sp.id             AS seller_product_id,
          sp.seller_id      AS seller_id,
          sp.product_id     AS product_id,
          sp.price          AS price,
          sp.quantity       AS quantity,
          sp.currency       AS currency,
          sp.expiry_date    AS expiry_date,
          sp.notes          AS notes,
          sp.updated_at     AS seller_updated_at,

          gp.id             AS global_product_id,
          gp.name           AS product_name,
          gp.barcode        AS barcode,
          gp.created_at     AS product_created_at,

          c.id              AS category_id,
          c.name            AS category_name

        FROM seller_products sp
        $joinType JOIN global_products gp ON sp.product_id = gp.id
        LEFT JOIN categories c ON gp.category_id = c.id
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
  Future<Result<List<SellerProduct>>> getAllProducts(String sellerId) async {
    try {
      final maps = await db.rawQuery(
        query: '''
        SELECT ${_sellerProductColumnsAndJoins()}
        WHERE sp.seller_id = ?
       ''',
        arguments: [sellerId],
      );
      final products = maps.map(SellerProductModel.fromRemote).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<SellerProduct>> getProductById(String sellerProductId) async {
    try {
      final response = await db.rawQuery(
        query: '''
          SELECT ${_sellerProductColumnsAndJoins()}
          WHERE sp.id = ?
          LIMIT 1
        ''',
        arguments: [sellerProductId],
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
    required String sellerId,
  }) async {
    try {
      if (!await isBarcodeExists(barcode)) return const SuccessState(null);

      final response = await db.rawQuery(
        query: '''
          SELECT ${_sellerProductColumnsAndJoins()}
          WHERE gp.barcode = ? 
          AND sp.seller_id = ? 
          LIMIT 1
        ''',
        arguments: [barcode, sellerId],
      );

      final map = response.firstOrNull;

      if (map != null) {
        final sellerProduct = SellerProductModel.fromLocal(map);
        return SuccessState(sellerProduct);
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
          SELECT ${_sellerProductColumnsAndJoins('RIGHT')}
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
  Future<Result<List<SellerProduct>>> searchProducts({
    required String query,
    required String sellerId,
  }) async {
    try {
      final maps = await db.rawQuery(
        query: '''
          SELECT ${_sellerProductColumnsAndJoins()}
          WHERE sp.id = ? 
          AND LOWER(sp.name) LIKE LOWER(?)
        ''',
        arguments: [sellerId, '%$query%'],
      );

      final products = maps.map(SellerProductModel.fromLocal).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getExpiredProducts(
    String sellerId,
  ) async {
    try {
      final today = DateTime.now().toIso8601String();
      final maps = await db.rawQuery(
        query: '''
          SELECT ${_sellerProductColumnsAndJoins()}
          WHERE sp.id = ?
          AND DATE(sp.expiry_date) <= DATE(?) 
        ''',
        arguments: [sellerId, today],
      );

      final products = maps.map(SellerProductModel.fromLocal).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(
    String sellerId,
    int days,
  ) async {
    try {
      final now = DateTime.now();
      final near = now.add(Duration(days: days)).toIso8601String();
      final maps = await db.rawQuery(
        query: '''
          SELECT ${_sellerProductColumnsAndJoins()}
          WHERE sp.id = ?
          AND DATE(sp.expiry_date) BETWEEN DATE(?) AND DATE(?) 
        ''',
        arguments: [sellerId, now.toIso8601String(), near],
      );

      final products = maps.map(SellerProductModel.fromLocal).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<void>> addProduct(SellerProduct product) async {
    try {
      if (!await isBarcodeExists(product.globalProduct.barcode ?? '')) {
        final globalProductModel =
            GlobalProductModel.fromEntity(product.globalProduct);
        await db.insertRow(
          table: 'global_products',
          map: globalProductModel.toMap(),
        );
      }

      final sellerProductModel = SellerProductModel.fromEntity(product);

      await db.insertRow(
        table: 'seller_products',
        map: sellerProductModel.toMap(),
      );

      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<void>> updateProduct(SellerProduct product) async {
    try {
      await db.update(
        table: 'seller_products',
        updated: SellerProductModel.fromEntity(product).toMap(),
        column: 'id',
        id: product.id,
      );

      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }
}
