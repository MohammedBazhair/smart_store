import '../../../errors/result.dart';
import 'product.dart';

/// واجهة مستودع المنتجات
abstract class ProductRepository {
  /// الحصول على جميع المنتجات
  Future<Result<List<Product>>> getAllProducts();

  /// الحصول على منتج بالمعرف
  Future<Result<Product>> getProductById(int id);

  /// الحصول على منتج بالباركود
  Future<Result<Product?>> getProductByBarcode(String barcode);

  Future<bool> isBarcodeExists(String barcode);

  /// البحث عن المنتجات
  Future<Result<List<Product>>> searchProducts(String query);

  /// تصفية المنتجات حسب الفئة
  Future<Result<List<Product>>> filterProductsByCategory(String category);

  /// الحصول على المنتجات المنتهية
  Future<Result<List<Product>>> getExpiredProducts();

  /// الحصول على المنتجات القريبة من الانتهاء
  Future<Result<List<Product>>> getNearExpiryProducts(int days);

  /// إضافة منتج جديد
  Future<Result<int>> addProduct(Product product);

  /// تحديث منتج
  Future<Result<void>> updateProduct(Product product);

  /// حذف منتج
  Future<Result<void>> deleteProduct(int id);

  /// حذف جميع المنتجات
  Future<Result<void>> deleteAllProducts();
}
