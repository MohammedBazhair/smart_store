import '../../../../core/database/local/local_database_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/seller_product.dart';
import '../models/seller_product_model.dart';

abstract class ProductLocalDataSource {
  Future<Result<List<Category>>> getAllCategories();
  Future<Result<List<SellerProduct>>> getAllProducts();
  Future<Result<SellerProduct>> getProductById(String id);
  Future<Result<SellerProduct?>> getProductByBarcode(String barcode);
  Future<bool> isBarcodeExists(String barcode);
  Future<Result<List<SellerProduct>>> searchProducts(String query);
  Future<Result<List<SellerProduct>>> filterProductsByCategory(
      String categoryKey);
  Future<Result<List<SellerProduct>>> getExpiredProducts();
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(int days);
  Future<Result<int>> addProduct(SellerProduct product);
  Future<Result<void>> updateProduct(SellerProduct product);
  Future<Result<void>> deleteProduct(String id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl(this.db);
  final LocalDatabaseService db;

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    try {
      final maps = await db.readRows(table: 'categories');
      final categories = maps.map(Category.fromMap).toList();
      return SuccessState(categories);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getAllProducts() async {
    try {
      final maps = await db.readRows(table: 'products');
      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<SellerProduct>> getProductById(String id) async {
    try {
      final maps = await db.readWhereArguments(
        table: 'products',
        where: 'id',
        whereArgs: [id],
      );
      if (maps.isEmpty) throw Exception('Product not found');
      return SuccessState(SellerProductModel.fromMap(maps.first));
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<SellerProduct?>> getProductByBarcode(String barcode) async {
    try {
      final maps = await db.readWhereArguments(
        table: 'products',
        where: 'barcode',
        whereArgs: [barcode],
      );

      if (maps.isEmpty) return const SuccessState(null);
      return SuccessState(SellerProductModel.fromMap(maps.first));
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<bool> isBarcodeExists(String barcode) async {
    final maps = await db.readWhereArguments(
      table: 'products',
      where: 'barcode',
      whereArgs: [barcode],
    );

    return maps.isNotEmpty;
  }

  @override
  Future<Result<List<SellerProduct>>> searchProducts(String query) async {
    try {
      final maps = await db.readWhereArguments(
        table: 'products',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );

      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> filterProductsByCategory(
    String categoryKey,
  ) async {
    try {
      final maps = await db.rawQuery(
        query: '''
        SELECT p.* FROM products p
        INNER JOIN categories c ON p.category_id = c.id
        WHERE c.key = ?
      ''',
        arguments: [categoryKey],
      );
      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getExpiredProducts() async {
    try {
      final today = DateTime.now().toIso8601String();
      final maps = await db.readWhereArguments(
        table: 'products',
        where: 'expiry_date <= ?',
        whereArgs: [today],
      );
      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(int days) async {
    try {
      final now = DateTime.now();
      final near = now.add(Duration(days: days)).toIso8601String();
      final maps = await db.readWhereArguments(
        table: 'products',
        where: 'expiry_date BETWEEN ? AND ?',
        whereArgs: [now.toIso8601String(), near],
      );
      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<int>> addProduct(SellerProduct product) async {
    try {
      final model = SellerProductModel.fromEntity(product);
      final id = await db.insertRow(
        table: 'products',
        map: model.toMap(),
      );
      return SuccessState(id);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<void>> updateProduct(SellerProduct product) async {
    try {
      await db.update(
        table: 'products',
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
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await db.delete(table: 'products', column: 'id', id: id);
      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }
}
