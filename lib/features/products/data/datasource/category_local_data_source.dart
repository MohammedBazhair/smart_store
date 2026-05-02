import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/database/local/query_where_builder.dart';
import '../../domain/entities/category.dart';

abstract class CategoryLocalDataSource {
  Future<Category?> fetchCategory(int categoryId);
  Future<List<Category>> fetchAllCategories();
  Future<void> setAllCategories(List<Category> categories);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CategoryLocalDataSourceImpl(this._db);
  final LocalDatabaseService _db;

  @override
  Future<List<Category>> fetchAllCategories() async {
    final maps = await _db.rawQuery(
      query: '''
      SELECT c.category_id     AS category_id,
             c.category_name   AS category_name,
             c.updated_at      AS category_updated_at
      FROM categories c''',
    );

    return maps.map(Category.fromLocal).toList();
  }

  @override
  Future<void> setAllCategories(List<Category> categories) async {
    for (final category in categories) {
      final result = await fetchCategory(category.id);

      if (result == null) {
        await _db.insertRow(map: category.toMap(), table: 'categories');
      } else {
        await _db.update(
          updated: category.toMapUpdate(),
          whereParams: WhereQueryParams(
            groups: [
              FilterGroup(
                filters: [Filter(column: 'category_id', value: category.id)],
              ),
            ],
          ),
          table: 'categories',
        );
      }
    }
  }

  @override
  Future<Category?> fetchCategory(int categoryId) async {
    final rows = await _db.query(
      table: 'categories',
      whereParams: WhereQueryParams(
        groups: [
          FilterGroup(
            filters: [Filter(column: 'category_id', value: categoryId)],
          ),
        ],
      ),
    );

    if (rows.isEmpty) return null;

    final category = Category.fromLocal(rows.first);
    return category;
  }
}
