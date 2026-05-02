import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/database/local/query_where_builder.dart';
import '../../domain/entities/product_query.dart';
import '../models/store_product_model.dart';
import '../product_query_builder.dart';

abstract class ProductSearchLocalDataSource {
  Future<List<StoreProductModel>> searchStoreProducts({
    required ProductQuery query,
    required String storeId,
  });

  Future<List<String>> searchProductsNamesSuggestions({
    required String query,
    required String storeId,
  });
}

class ProductSearchLocalDataSourceImpl implements ProductSearchLocalDataSource {
  ProductSearchLocalDataSourceImpl(this._db);
  final LocalDatabaseService _db;

  @override
  Future<List<StoreProductModel>> searchStoreProducts({
    required ProductQuery query,
    required String storeId,
  }) async {
    final queryRaw = StringBuffer('''
          SELECT ${ProductQueryBuilder.storeProductColumnsAndJoins}
          WHERE sp.store_id = ? 
          AND sp.is_deleted = 0
        ''');

    if (query.hasCategory) queryRaw.write(' AND c.category_id = ?');
    if (query.isSearching) queryRaw.write(' AND LOWER(gp.name) LIKE LOWER(?)');
    switch (query.sortType) {
      case ProductSortType.quantityAsc:
        queryRaw.write(' ORDER BY sp.quantity ASC NULLS LAST');
        break;
      case ProductSortType.quantityDesc:
        queryRaw.write(' ORDER BY sp.quantity DESC NULLS LAST');
        break;
      case ProductSortType.expiryAsc:
        queryRaw.write(' ORDER BY sp.expiry_date ASC NULLS LAST');
        break;
      case ProductSortType.expiryDesc:
        queryRaw.write(' ORDER BY sp.expiry_date DESC NULLS LAST');
        break;
    }

    final maps = await _db.rawQuery(
      query: queryRaw.toString(),
      arguments: [
        storeId,
        if (query.hasCategory) query.category?.id,
        if (query.isSearching) '%${query.search}%',
      ],
    );

    return maps.map(StoreProductModel.fromLocal).toList();
  }

  @override
  Future<List<String>> searchProductsNamesSuggestions({
    required String query,
    required String storeId,
  }) async {
    final whereParams = WhereQueryParams(
      groups: [
        FilterGroup(
          filters: [
            Filter(
              column: 'name',
              value: '%$query%',
              operator: FilterOperator.like,
            ),
          ],
        ),
      ],
    );

    final result = await _db.query(
      table: 'global_products',
      whereParams: whereParams,
      columns: ['name'],
    );

    return result.map((r)=>r['name'] as String).toList();
  }
}
