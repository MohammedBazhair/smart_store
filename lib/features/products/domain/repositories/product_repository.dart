import '../../../../core/constants/typedef.dart';
import '../../../../errors/result.dart';
import '../../data/models/store_product_key.dart';
import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/product_query.dart';
import '../entities/store_product.dart';
import '../entities/sub_entities/global_product.dart';

abstract class ProductRepository {
  Future<List<Category>> getAllCategories();

  Future<List<GlobalProduct>> getGlobalProducts();
  Future<GlobalProduct?> getGlobalProductByBarcode(String barcode);

  Future<ProductsByIdentifier> getStoreProducts(String storeId);
  Future<List<StoreProduct>> getWithoutBarcodeProducts(String storeId);
  Future<StoreProduct?> getStoreProductById(StoreProductKey key);
  Future<List<StoreProduct>> searchProducts({
    required ProductQuery query,
    required String storeId,
  });
  Future<List<StoreProduct>> getExpiredProducts(String storeId);
  Future<List<StoreProduct>> getNearExpiryProducts(String storeId, int days);

  Future<Result<StoreProduct>> addProduct(StoreProduct product);
  Future<Result<void>> updateProduct(Product product);

  Future<void> initializeDataFromNetwork();
  Future<void> syncAllProducts([String? storeId]);
  Future<void> syncAllCategories();

  Future<void> deleteProduct(StoreProductKey key);
}
