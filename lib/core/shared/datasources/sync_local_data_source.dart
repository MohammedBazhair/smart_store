import '../../constants/enums.dart';
import '../../constants/log.dart';
import '../../database/local/local_database_service.dart';
import '../data/models/sync_change_model.dart';
import '../data/models/sync_state_model.dart';

abstract class SyncLocalDataSource {
  Future<void> addChange(SyncChangeModel change);

  Future<List<SyncChangeModel>> getTableChanges(String table);

  Future<void> deleteChange(int id);

  Future<void> clearTablesChanges(String table);

  Future<void> saveLastSynced(SyncStateModel state);

  Future<SyncStateModel?> getLastSynced(String tableName);
}

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  SyncLocalDataSourceImpl(this._db);
  final LocalDatabaseService _db;

  @override
  Future<void> addChange(SyncChangeModel change) async {
    final existing = await _db.readRowsWhere(
      table: 'sync_changes',
      filters: {
        'table_name': change.tableName,
        'record_id': change.recordId,
      },
    );

    if (existing.isEmpty) {
      await _db.insertRow(
        table: 'sync_changes',
        map: change.toMap(),
      );

      return;
    }

    final oldChange = SyncChangeModel.fromMap(existing.first);

    SyncOperation newOperation = change.operation;

    if (oldChange.operation == SyncOperation.insert &&
        change.operation == SyncOperation.delete) {
      await deleteChange(oldChange.id!);
      return;
    }

    if (oldChange.operation == SyncOperation.insert &&
        change.operation == SyncOperation.update) {
      newOperation = SyncOperation.insert;
    }

    if (oldChange.operation == SyncOperation.update &&
        change.operation == SyncOperation.update) {
      newOperation = SyncOperation.update;
    }

    await _db.update(
      updated: {'operation': newOperation.name},
      filterWhere: {'id': oldChange.id},
      table: 'sync_changes',
    );
  }

  @override
  Future<List<SyncChangeModel>> getTableChanges(String table) async {
    try {
      final maps = await _db.readRowsWhere(
        table: 'sync_changes',
        filters: {'table_name': table},
      );
      
      return maps.map(SyncChangeModel.fromMap).toSet().toList();
    } catch (e,st) {
      Logger.debugLog(error: e,stackTrace: st);
      return [];
    }
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

  @override
  Future<void> saveLastSynced(SyncStateModel state) async {
    final existing = await getLastSynced(state.tableName);

    if (existing != null) {
      await _db.update(
        table: 'sync_state',
        updated: state.toMap(),
        filterWhere: {'table_name': state.tableName},
      );
    } else {
      await _db.insertRow(
        table: 'sync_state',
        map: state.toMap(),
      );
    }
  }

  @override
  Future<SyncStateModel?> getLastSynced(String tableName) async {
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
