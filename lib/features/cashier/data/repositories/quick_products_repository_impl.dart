import '../../../../core/constants/log.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/database/local/query_where_builder.dart';
import '../../../products/data/models/store_product_key.dart';
import '../../domain/repositories/quick_products_repository.dart';

class QuickProductsRepositoryImpl extends QuickProductsRepository {
  QuickProductsRepositoryImpl(this._localDatabase);

  final LocalDatabaseService _localDatabase;

  static const String _quickProductsTable = 'quick_products';

  @override
  Future<void> addQuickProduct(StoreProductKey productKey) async {
    await _localDatabase.insertRow(
      map: productKey.toMap(),
      table: _quickProductsTable,
    );
  }

  @override
  Future<void> removeQuickProduct(StoreProductKey productKey) async {
    await _localDatabase.deleteWhere(
      table: _quickProductsTable,
      whereParams: productKey.getWhereParams(),
    );
  }

  @override
  Future<bool> isQuickProduct(StoreProductKey productKey) async {
    try {
      final row = await _localDatabase.query(
        table: _quickProductsTable,
        whereParams: productKey.getWhereParams(),
      );

      return row.first.isNotEmpty;
    } on StateError catch (_) {
      return false;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<List<String>> getQuickProductsIds(String storeId) async {
    final whwereParams = WhereQueryParams(
      groups: [
        FilterGroup(
          filters: [
            Filter(
              column: 'store_id',
              value: storeId,
            ),
          ],
        ),
      ],
    );

    final rows = await _localDatabase.query(
      table: _quickProductsTable,
      whereParams: whwereParams,
    );

    return rows.map((m)=> m['product_id'] as String).toList();
  }
}
