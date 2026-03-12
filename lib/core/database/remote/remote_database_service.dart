import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/typedef.dart';

abstract interface class RemoteDatabaseService {
  SupabaseClient get client;
  Future<Map<String, dynamic>> insertRow({
    required Map<String, dynamic> map,
    required String table,
  });

  Future<void> insertRows({
    required RowList rows,
    required String table,
  });

  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
    List<String> selectColumns = const ['*'],
  });

  Future<List<Map<String, dynamic>>> readRowsWhere({
    required String table,
    required Map<String, Object> filters,
  });

  Future<List<Map<String, dynamic>>> readRows({required String table});

  Stream readRowsRealTime({
    required String table,
    required List<String> primaryKey,
    required String column,
    required String value,
  });

  Future<dynamic> update({
    required Map<String, dynamic> updated,
    required String table,
    required Map<String, Object> whereFilter,
  });

  Future<void> updateRows({
    required RowList rows,
    required String table,
    required String onConflict,
  });

  Future<void> delete({
    required String id,
    required String column,
    required String table,
  });

  Future<void> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  });

  Future<List<Map<String, dynamic>>> readRowsWhereIn({
    required String table,
    required String column,
    required List<dynamic> values,
    List<String> columnsSelect = const ['*'],
  });

  Future<void> upsertRow({
    required String table,
    required Map<String, dynamic> row,
     String? onConflict,
  });
}

class RemoteDatabaseServiceImpl implements RemoteDatabaseService {
  RemoteDatabaseServiceImpl(this._client);
  final SupabaseClient _client;

  @override
  SupabaseClient get client => _client;

  String _listToSelectColumns(List<String> columns) {
    return columns.join(', ');
  }

  @override
  Future<Map<String, dynamic>> insertRow({
    required Map<String, dynamic> map,
    required String table,
  }) {
    return _client.from(table).insert(map).select().single();
  }

  @override
  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
    List<String> selectColumns = const ['*'],
  }) {
    final columnsString = _listToSelectColumns(selectColumns);
    return _client.from(table).select(columnsString).eq(column, id).single();
  }

  @override
  Future<List<Map<String, dynamic>>> readRows({required String table}) {
    return _client.from(table).select();
  }

  @override
  Future<dynamic> update({
    required Map<String, dynamic> updated,
    required String table,
    required Map<String, Object> whereFilter,
  }) async {
    try {
      final lastResponse =
          _client.from(table).update(updated).match(whereFilter);
      return await lastResponse;
    } catch (e) {
      debugPrint(e.toString());
      return Future.value();
    }
  }

  @override
  Future<void> delete({
    required String id,
    required String column,
    required String table,
  }) {
    try {
      return _client.from(table).delete().eq(column, id);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value();
    }
  }

  @override
  Stream readRowsRealTime({
    required String table,
    required List<String> primaryKey,
    required String column,
    required String value,
  }) {
    return _client.from(table).stream(primaryKey: primaryKey).eq(column, value);
  }

  @override
  Future<void> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  }) async {
    try {
      await _client.from(table).delete().match(filters);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readRowsWhere({
    required String table,
    required Map<String, Object> filters,
  }) {
    try {
      return _client.from(table).select().match(filters);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(<Map<String, dynamic>>[]);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readRowsWhereIn({
    required String table,
    required String column,
    required List<dynamic> values,
    List<String> columnsSelect = const ['*'],
  }) {
    try {
      final columnsString = _listToSelectColumns(columnsSelect);
      return _client.from(table).select(columnsString).inFilter(column, values);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value([]);
    }
  }

  @override
  Future<void> insertRows({
    required RowList rows,
    required String table,
  }) async {
    try {
      return await _client.from(table).insert(rows);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> updateRows({
    required RowList rows,
    required String table,
    required String onConflict,
  }) async {
    await _client.from(table).upsert(rows, onConflict: onConflict);
  }

  @override
  Future<void> upsertRow({
    required String table,
    required Map<String, dynamic> row,
    String? onConflict,

  }) async {
    await _client.from(table).upsert(row, onConflict: onConflict);
  }
}
