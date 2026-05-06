import 'package:sqflite/sqflite.dart';
import '../../constants/typedef.dart';
import 'database_helper.dart';
import 'query_where_builder.dart';

abstract interface class LocalDatabaseService {
  Future<Batch> get batch;

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
    List<String>? columns,
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
  LocalDatabaseServiceImpl();

  Future<Database> get _database => DatabaseHelper.instance.database;

  @override
  Future<Batch> get batch async => (await _database).batch();

  @override
  Future<int> insertRow({
    required String table,
    required Map<String, dynamic> map,
  }) async {
    final _db = await _database;
    return _db.insert(
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
    final _batch = await batch;

    for (final row in rows) {
      _batch.insert(table, row, conflictAlgorithm: conflictAlgorithm);
    }

    await _batch.commit(noResult: true);
  }

  @override
  Future<int> deleteWhere({
    required String table,
    WhereQueryParams? whereParams,
  }) async {
    final _db = await _database;

    final (:where, :whereArgs) = WhereQueryBuilder.build(whereParams);

    return _db.delete(
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
    List<String>? columns,
  }) async {
    final _db = await _database;

    final (:where, :whereArgs) = WhereQueryBuilder.build(whereParams);

    return _db.query(
      table,
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
      columns: columns,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery({
    required String query,
    List<Object?>? arguments,
  }) async{
    final _db = await _database;

    return _db.rawQuery(query, arguments);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  }) async{
    final _db = await _database;

    return _db.transaction(action, exclusive: exclusive);
  }

  @override
  Future<int> update({
    required String table,
    required Map<String, dynamic> updated,
    WhereQueryParams? whereParams,
  })async {
    final _db = await _database;

    final (:where, :whereArgs) = WhereQueryBuilder.build(whereParams);

    return _db.update(
      table,
      updated,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
