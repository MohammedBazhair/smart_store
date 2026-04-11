import 'package:sqflite/sqflite.dart';
import '../../constants/typedef.dart';
import 'query_where_builder.dart';

abstract interface class LocalDatabaseService {
  Batch get batch;

  Future<int> insertRow({
    required Map<String, dynamic> map,
    required String table,
  });

  Future<void> insertRows({
    required RowList rows,
    required String table,
    ConflictAlgorithm? conflictAlgorithm,
  });

  Future<List<Map<String, dynamic>>> rawQuery({
    required String query,
    List<Object?>? arguments,
  });

  Future<List<Map<String, dynamic>>> query({
    required String table,
    WhereQueryParams? whereParams,
    String? orderBy,
  });

  Future<int> update({
    required String table,
    required Map<String, dynamic> updated,
    WhereQueryParams? whereParams,
  });

  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  });

  Future<int> deleteWhere({
    required String table,
    WhereQueryParams? whereParams,
  });
}

class LocalDatabaseServiceImpl implements LocalDatabaseService {
  LocalDatabaseServiceImpl(this._database);
  final Database _database;

  @override
  Batch get batch => _database.batch();

 

  @override
  Future<int> insertRow({
    required String table,
    required Map<String, dynamic> map,
  }) {
    return _database.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertRows({
    required String table,
    required RowList rows,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final batch = _database.batch();

    for (final row in rows) {
      batch.insert(table, row, conflictAlgorithm: conflictAlgorithm);
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<int> deleteWhere({
    required String table,
    WhereQueryParams? whereParams,
  }) {
    final (:where,:whereArgs) = WhereQueryBuilder.build(whereParams);

    return _database.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> query({
    required String table,
     WhereQueryParams? whereParams,
    String? orderBy,
  }) {
    final (:where, :whereArgs) = WhereQueryBuilder.build(whereParams);

    return _database.query(
      table,
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
    );
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
    return _database.transaction(action, exclusive: exclusive);
  }

  @override
  Future<int> update({
    required String table,
    required Map<String, dynamic> updated,
    WhereQueryParams? whereParams,
  }) {
    final (:where, :whereArgs) = WhereQueryBuilder.build(whereParams);

    return _database.update(
      table,
      updated,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
