import '../../../../errors/result.dart';
import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/store_product.dart';
import '../entities/sub_entities/global_product.dart';

abstract class ProductRepository {
  Future<List<Category>> getAllCategories();
  Future<List<StoreProduct>> getAllProducts(String storeId);

  Future<List<GlobalProduct>> getProductsGlobal();

  Future<Result<StoreProduct>> getProductById(String sellerProductId);

  Future<Product?> getProductByBarcode({
    required String barcode,
    required String storeId,
  });

  Future<bool> isBarcodeExists(String barcode);

  Future<List<StoreProduct>> searchProducts({
    required String query,
    required String storeId,
  });

  Future<Result<List<StoreProduct>>> getExpiredProducts(String storeId);

  Future<Result<List<StoreProduct>>> getNearExpiryProducts(
    String storeId,
    int days,
  );

  Future<Result<void>> addProduct(StoreProduct product);

  Future<Result<void>> updateProduct(StoreProduct product);

  Future<void> initDataFromNetwork();
}
