import '../../../../errors/result.dart';
import '../entities/category.dart';
import '../entities/seller_product.dart';

abstract class ProductRepository {
  Future<Result<List<Category>>> getAllCategories();
  Future<Result<List<SellerProduct>>> getAllProducts(String sellerId);

  Future<Result<SellerProduct>> getProductById(String id);

  Future<SellerProduct?> getProductByBarcode(String barcode);

  Future<bool> isBarcodeExists(String barcode);

  Future<Result<List<SellerProduct>>> searchProducts(String query);

  Future<Result<List<SellerProduct>>> filterProductsByCategory(String category);

  Future<Result<List<SellerProduct>>> getExpiredProducts();

  Future<Result<List<SellerProduct>>> getNearExpiryProducts(int days);

  Future<Result<int>> addProduct(SellerProduct product);

  Future<Result<void>> updateProduct(SellerProduct product);

  Future<Result<void>> deleteProduct(String id);

  Future<Result<void>> deleteAllProducts();
}
