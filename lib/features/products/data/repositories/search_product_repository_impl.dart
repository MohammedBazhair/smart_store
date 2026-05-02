import '../../../../core/constants/log.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/search_product_repository.dart';
import '../datasource/product_search_local_data_source.dart';

class SearchProductRepositoryImpl implements SearchProductRepository {
  SearchProductRepositoryImpl(this._localSearch);

  final ProductSearchLocalDataSource _localSearch;

  @override
  Future<List<StoreProduct>> searchStoreProducts({
    required ProductQuery query,
    required String storeId,
  }) {
    try {
      return _localSearch.searchStoreProducts(
        query: query,
        storeId: storeId,
      );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value([]);
    }
  }

  @override
  Future<List<String>> searchProductsNamesSuggestions({
    required String query,
    required String storeId,
  }) {
    try {
      return _localSearch.searchProductsNamesSuggestions(
        query: query,
        storeId: storeId,
      );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return Future.value([]);
    }
  }
}
