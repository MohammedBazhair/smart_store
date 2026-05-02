import '../entities/product_query.dart';
import '../entities/store_product.dart';

abstract class SearchProductRepository {
  Future<List<StoreProduct>> searchStoreProducts({
    required ProductQuery query,
    required String storeId,
  });

  Future<List<String>> searchProductsNamesSuggestions({
    required String query,
    required String storeId,
  });
}
