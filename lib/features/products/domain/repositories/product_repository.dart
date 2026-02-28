import '../../../../errors/result.dart';
import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/seller_product.dart';

abstract class ProductRepository {
  Future<Result<List<Category>>> getAllCategories();
  Future<List<SellerProduct>> getAllProducts(String sellerId);

  Future<Result<SellerProduct>> getProductById(String sellerProductId);

  Future<Product?> getProductByBarcode({
    required String barcode,
    required String sellerId,
  });

  Future<bool> isBarcodeExists(String barcode);

  Future<List<SellerProduct>> searchProducts({
    required String query,
    required String sellerId,
  });

  Future<Result<List<SellerProduct>>> getExpiredProducts(String sellerId);

  Future<Result<List<SellerProduct>>> getNearExpiryProducts(
    String sellerId,
    int days,
  );

  Future<Result<void>> addProduct(SellerProduct product);

  Future<Result<void>> updateProduct(SellerProduct product);
}
