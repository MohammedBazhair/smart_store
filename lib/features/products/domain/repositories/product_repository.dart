import '../../../../core/constants/typedef.dart';
import '../../../../errors/result.dart';
import '../entities/category.dart';
import '../entities/store_product.dart';
import '../entities/sub_entities/global_product.dart';

abstract class ProductRepository {
  Future<List<Category>> getAllCategories();
  Future<ProductsByIdentifier> getStoreProducts(String storeId);

  Future<List<GlobalProduct>> getProductsGlobal();

  Future<Result<StoreProduct>> getProductById(String sellerProductId);

  Future<GlobalProduct?> getGlobalProductByBarcode(String barcode);

  Future<List<StoreProduct>> searchProducts({
    required String query,
    required String storeId,
  });

  Future<Result<List<StoreProduct>>> getExpiredProducts(String storeId);

  Future<Result<List<StoreProduct>>> getNearExpiryProducts(
    String storeId,
    int days,
  );

  Future<Result<StoreProduct>> addProduct(StoreProduct product);

  Future<Result<void>> updateProduct(StoreProduct product);

  Future<void> initDataFromNetwork();
}
