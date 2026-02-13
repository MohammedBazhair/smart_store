import '../../../core/data/database_helper.dart';
import '../../../errors/exceptions.dart';
import '../../../errors/result.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';
import 'product_model.dart';

/// تنفيذ مستودع المنتجات
class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<Result<List<Product>>> getAllProducts() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'products',
        orderBy: 'created_at DESC',
      );
      final products = maps.map(ProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState('فشل في جلب المنتجات: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product>> getProductById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        return const ErrorState('المنتج غير موجود');
      }
      final product = ProductModel.fromMap(maps.first);
      return SuccessState(product);
    } catch (e) {
      return const ErrorState('فشل في جلب المنتج');
    }
  }

  @override
  Future<Result<Product?>> getProductByBarcode(String barcode) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'products',
        where: 'barcode = ?',
        whereArgs: [barcode],
      );
      if (maps.isEmpty) {
        return const SuccessState(null);
      }
      final product = ProductModel.fromMap(maps.first);
      return SuccessState(product);
    } catch (e) {
      return ErrorState('فشل في جلب المنتج: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'products',
        where: 'LOWER(name) LIKE LOWER(?) OR LOWER(barcode) LIKE LOWER(?)',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      final products = maps.map(ProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState('فشل في البحث: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> filterProductsByCategory(
    String category,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'products',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
      final products = maps.map(ProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState('فشل في التصفية: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> getExpiredProducts() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().toIso8601String();
      final maps = await db.query(
        'products',
        where: 'expiry_date < ?',
        whereArgs: [now],
        orderBy: 'expiry_date ASC',
      );
      final products = maps.map(ProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(
        'فشل في جلب المنتجات المنتهية: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<List<Product>>> getNearExpiryProducts(int days) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final threshold = now.add(Duration(days: days)).toIso8601String();
      final maps = await db.query(
        'products',
        where: 'DATE(expiry_date) BETWEEN DATE(?) AND DATE(?)',
        whereArgs: [threshold, now.toIso8601String()],
        orderBy: 'expiry_date ASC',
      );
      final products = maps.map(ProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(
        'فشل في جلب المنتجات القريبة من الانتهاء: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isBarcodeExists(String barcode) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    return result.isNotEmpty;
  }

  @override
  Future<Result<int>> addProduct(Product product) async {
    try {
      final barcode = product.barcode;
      if (barcode == null) throw ArgumentError();

      if (await isBarcodeExists(barcode)) {
        throw const DuplicateBarcodeException();
      }

      final db = await _dbHelper.database;
      final model = ProductModel.fromEntity(product);

      final id = await db.insert('products', model.toMap());
      return SuccessState(id);
    } on ArgumentError {
      return const ErrorState(
        'فشل في إضافة المنتج: لم يتم تحديد الباركود',
      );
    } on DuplicateBarcodeException catch (e) {
      return ErrorState(e.message);
    } catch (e) {
      return ErrorState('فشل في إضافة المنتج: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> updateProduct(Product product) async {
    try {
      final db = await _dbHelper.database;

      final model = ProductModel.fromEntity(product);
      await db.update(
        'products',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      return const SuccessState(null);
    } catch (e) {
      return const ErrorState('فشل في تحديث المنتج');
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const SuccessState(null);
    } catch (e) {
      return ErrorState('فشل في حذف المنتج: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteAllProducts() async {
    try {
      final db = await _dbHelper.database;
      await db.delete('products');
      return const SuccessState(null);
    } catch (e) {
      return ErrorState('فشل في حذف جميع المنتجات: ${e.toString()}');
    }
  }
}
