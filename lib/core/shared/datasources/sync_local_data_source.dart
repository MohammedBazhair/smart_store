import '../../database/local/local_database_service.dart';
import '../data/models/sync_change_model.dart';
import '../data/models/sync_state_model.dart';

abstract class SyncLocalDataSource {
  /// =====================
  /// sync_changes
  /// =====================

  Future<void> addChange(SyncChangeModel change);

  Future<List<SyncChangeModel>> getTableChanges(String table);

  Future<void> deleteChange(int id);

  Future<void> clearTablesChanges(String table);

  /// =====================
  /// sync_state
  /// =====================

  Future<void> saveLastSync(SyncStateModel state);

  Future<SyncStateModel?> getLastSync(String tableName);
}

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  SyncLocalDataSourceImpl(this._db);
  final LocalDatabaseService _db;

  // ===================== sync_changes =====================
  @override
  Future<void> addChange(SyncChangeModel change) async {
    await _db.insertRow(
      table: 'sync_changes',
      map: change.toMap(),
    );
  }

  @override
  Future<List<SyncChangeModel>> getTableChanges(String table) async {
    final maps = await _db.readRowsWhere(
      table: 'sync_changes',
      filters: {'table_name': getTableChanges},
    );
    return maps.map(SyncChangeModel.fromMap).toList();
  }

  @override
  Future<void> deleteChange(int id) async {
    await _db.delete(
      table: 'sync_changes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearTablesChanges(String table) async {
    await _db
        .deleteWhere(table: 'sync_changes', filters: {'table_name': table});
  }

  // ===================== sync_state =====================
  @override
  Future<void> saveLastSync(SyncStateModel state) async {
    await _db.insertRow(
      table: 'sync_state',
      map: state.toMap(),
    );
  }

  @override
  Future<SyncStateModel?> getLastSync(String tableName) async {
    final maps = await _db.readRowsWhere(
      table: 'sync_state',
      filters: {
        'table_name': tableName,
      },
    );

    if (maps.isEmpty) return null;

    return SyncStateModel.fromMap(maps.first);
  }
}
