import 'package:sqflite/sqflite.dart';

import '../../constants/enums.dart';
import '../../constants/log.dart';
import '../../database/local/local_database_service.dart';
import '../../database/local/query_where_builder.dart';
import '../data/models/sync_change_model.dart';
import '../data/models/sync_state_model.dart';

abstract class SyncLocalDataSource {
  Future<void> addChange(SyncChangeModel change, [Transaction? transaction]);

  Future<List<SyncChangeModel>> getTableChanges(String table);

  Future<void> deleteChange(int id, [Transaction? transaction]);

  Future<void> clearTablesChanges(String table);

  Future<void> saveLastSynced(SyncStateModel state);

  Future<SyncStateModel?> getLastSynced(String tableName);
}

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  SyncLocalDataSourceImpl(this._db);
  final LocalDatabaseService _db;

  @override
  Future<void> addChange(
    SyncChangeModel change, [
    Transaction? transaction,
  ]) async {
    final isInTransaction = transaction != null;
    final existing = isInTransaction
        ? await transaction.query(
            'sync_changes',
            where: 'table_name = ? AND record_id = ?',
            whereArgs: [change.tableName, change.recordId],
          )
        : await _db.query(
            table: 'sync_changes',
            whereParams: WhereQueryParams(
              groups: [
                FilterGroup(
                  filters: [
                    Filter(column: 'table_name', value: change.tableName),
                    Filter(column: 'record_id', value: change.recordId),
                  ],
                ),
              ],
            ),
          );

    if (existing.isEmpty) {
      isInTransaction
          ? await transaction.insert('sync_changes', change.toMap())
          : await _db.insertRow(
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

    final updatedValues = {'operation': newOperation.name};
    if (isInTransaction) {
      await transaction.update(
        'sync_changes',
        updatedValues,
        where: 'id = ?',
        whereArgs: [oldChange.id],
      );
    } else {
      await _db.update(
        updated: updatedValues,
        whereParams: WhereQueryParams(
          groups: [
            FilterGroup(
              filters: [Filter(column: 'id', value: oldChange.id!)],
            ),
          ],
        ),
        table: 'sync_changes',
      );
    }
  }

  @override
  Future<List<SyncChangeModel>> getTableChanges(String table) async {
    try {
      final maps = await _db.query(
        table: 'sync_changes',
        whereParams: WhereQueryParams(
          groups: [
            FilterGroup(
              filters: [Filter(column: 'table_name', value: table)],
            ),
          ],
        ),
      );

      return maps.map(SyncChangeModel.fromMap).toSet().toList();
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> deleteChange(int id, [Transaction? transaction]) async {
    if (transaction != null) {
      await transaction.delete('sync_changes', where: 'id = ?', whereArgs: [id]);
    } else {
      await _db.deleteWhere(
        table: 'sync_changes',
        whereParams: WhereQueryParams(
          groups: [
            FilterGroup(filters: [Filter(column: 'id', value: id)]),
          ],
        ),
      );
    }
  }

  @override
  Future<void> clearTablesChanges(String table) async {
    await _db.deleteWhere(
      table: 'sync_changes',
      whereParams: WhereQueryParams(
        groups: [
          FilterGroup(
            filters: [Filter(column: 'table_name', value: table)],
          ),
        ],
      ),
    );
  }

  @override
  Future<void> saveLastSynced(SyncStateModel state) async {
    final existing = await getLastSynced(state.tableName);

    if (existing != null) {
      await _db.update(
        table: 'sync_state',
        updated: state.toMap(),
        whereParams: WhereQueryParams(
          groups: [
            FilterGroup(
              filters: [Filter(column: 'table_name', value: state.tableName)],
            ),
          ],
        ),
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
    final maps = await _db.query(
      table: 'sync_state',
      whereParams: WhereQueryParams(
        groups: [
          FilterGroup(
            filters: [Filter(column: 'table_name', value: tableName)],
          ),
        ],
      ),
    );

    if (maps.isEmpty) return null;

    return SyncStateModel.fromMap(maps.first);
  }
}
