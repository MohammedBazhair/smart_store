import 'package:sqflite/sqflite.dart';
import '../../constants/typedef.dart';

abstract interface class LocalDatabaseService {
  Future<int> insertRow({
    required Map<String, dynamic> map,
    required String table,
  });

  Future<void> insertRows({required RowList rows, required String table});

  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
  });

  Future<List<Map<String, dynamic>>> rawQuery({
    required String query,
    List<Object?>? arguments,
  });

  Future<List<Map<String, dynamic>>> readWhereArguments({
    required String table,
    String? where,
    List<Object?>? whereArgs,
  });

  Future<List<Map<String, dynamic>>> readRowsWhere({
    required String table,
    required Map<String, Object> filters,
  });

  Future<List<Map<String, dynamic>>> readRows({required String table});

  Stream<RowList> readRowsRealTime({required String table});

  Future<int> update({
    required Map<String, dynamic> updated,
    required Map<String, dynamic> filterWhere,
    required String table,
  });

  Future<int> delete({
    required String id,
    required String column,
    required String table,
  });

  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  });

  Future<int> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  });
}

class LocalDatabaseServiceImpl implements LocalDatabaseService {
  LocalDatabaseServiceImpl(this._database);
  final Database _database;

  @override
  Future<int> insertRow({
    required Map<String, dynamic> map,
    required String table,
  }) {
    return _database.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
  }) async {
    final result = await _database.rawQuery(
      'SELECT * FROM $table WHERE $column = ?',
      [id],
    );
    return result.elementAtOrNull(0) ?? {};
  }

  @override
  Future<List<Map<String, dynamic>>> readRows({required String table}) {
    return _database.rawQuery('SELECT * FROM $table');
  }

  @override
  Future<int> delete({
    required String id,
    required String column,
    required String table,
  }) {
    return _database.delete(table, where: '$column = ?', whereArgs: [id]);
  }

  @override
  Future<int> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  }) {
    final whereClause =
        filters.entries.map((e) => '${e.key} = ?').join(' AND ');

    return _database.delete(
      table,
      where: whereClause,
      whereArgs: filters.values.toList(),
    );
  }

  @override
  Stream<RowList> readRowsRealTime({required String table}) {
    final future = readRows(table: table);
    return Stream.fromFuture(future);
  }

  @override
  Future<List<Map<String, dynamic>>> readRowsWhere({
    required String table,
    required Map<String, Object> filters,
  }) {
    final whereClause =
        filters.entries.map((e) => '${e.key} = ?').join(' AND ');
    return _database.rawQuery('SELECT * FROM $table WHERE $whereClause', []);
  }

  @override
  Future<void> insertRows({
    required RowList rows,
    required String table,
  }) async {
    final batch = _database.batch();

    for (final map in rows) {
      batch.insert(table, map, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<List<Map<String, dynamic>>> readWhereArguments({
    required String table,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final result = await _database.query(
      table,
      where: where,
      whereArgs: whereArgs,
    );
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery({
    required String query,
    List<Object?>? arguments,
  }) {
    return _database.rawQuery(query, arguments);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  }) {
    return _database.transaction(action);
  }

  @override
  Future<int> update({
    required Map<String, dynamic> updated,
    required Map<String, dynamic> filterWhere,
    required String table,
  }) {
    final where = filterWhere.keys.map((k) => '$k = ?').join(' AND ');
    final whereArgs = filterWhere.values.toList();
    return _database.update(
      table,
      updated,
      where:filterWhere.isEmpty? null: where,
      whereArgs: filterWhere.isEmpty ? null : whereArgs,
    );
  }
}
