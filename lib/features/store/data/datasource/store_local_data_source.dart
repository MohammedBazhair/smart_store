import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/shared/data/models/sync_change_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../../user/domain/entities/role.dart';
import '../models/store_member_key.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

abstract class StoreLocalDataSource {
  Future<void> addStore(StoreModel store, [bool skipLocalTracking = false]);
  Future<StoreModel?> getStore(String storeId);
  Future<void> updateStore(StoreModel store, [bool skipLocalTracking = false]);
  Future<void> removeStore(String storeId, [bool skipLocalTracking = false]);
  Future<List<StoreModel>> getUserStores({
    required String userPhone,
    bool includeDeleted = true,
  });
  Future<void> upsertStores(
    List<StoreModel> stores, [
    bool skipLocalTracking = false,
  ]);

  Future<List<StoreMemberModel>> getMembers({
    required String storeId,
    bool includeDeleted = true,
  });
  Future<void> insertStoreMember(
    StoreMemberModel member, [
    bool skipLocalTracking = false,
  ]);
  Future<void> updateStoreMember(
    StoreMemberModel member, [
    bool skipLocalTracking = false,
  ]);
  Future<void> upsertMembers(
    List<StoreMemberModel> members, [
    bool skipLocalTracking = false,
  ]);
  Future<void> deleteStoreMember({
    required StoreMemberKey key,
    bool skipLocalTracking = false,
  });
  Future<StoreMemberModel?> getStoreMember(StoreMemberKey key);
}

class StoreLocalDataSourceImpl implements StoreLocalDataSource {
  StoreLocalDataSourceImpl(this._db, this._sync);

  final LocalDatabaseService _db;
  final SyncLocalDataSource _sync;

  Future<void> _updateStore(String storeId) async {
    await _db.update(
      updated: {'updated_at': DateTime.now().toUtc().toIso8601String()},
      table: 'stores',
      filterWhere: {'id': storeId},
    );
  }

  @override
  Future<void> addStore(
    StoreModel store, [
    bool skipLocalTracking = false,
  ]) async {
    try {
      final member = StoreMemberModel(
        memberPhone: store.ownerPhone,
        storeId: store.id!,
        role: Role.storeOwner,
        createdAt: store.createdAt,
        updatedAt: store.createdAt,
        isDeleted: false,
      );

      await _db.transaction((t) async {
        await t.insert('stores', store.toMap());
        await t.insert('store_members', member.toMap());
      });

      if (skipLocalTracking) return;

      final storeChange = SyncChangeModel(
        tableName: 'stores',
        recordId: store.id!,
        operation: SyncOperation.insert,
        updatedAt: DateTime.now().toUtc(),
      );
      await _sync.addChange(storeChange);

      final memberKey =
          StoreMemberKey(storeId: store.id!, memberPhone: member.memberPhone);
      final memberChange = SyncChangeModel(
        tableName: 'store_members',
        recordId: memberKey.toJson(),
        operation: SyncOperation.insert,
        updatedAt: DateTime.now().toUtc(),
      );
      await _sync.addChange(memberChange);
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }

  @override
  Future<List<StoreModel>> getUserStores({
    required String userPhone,
    bool includeDeleted = true,
  }) async {
    const queryIsDeleted = ' AND s.is_deleted = 0 AND m.is_deleted = 0';
    final query = StringBuffer('''
        SELECT s.*
        FROM stores s
        JOIN store_members m
        ON s.id = m.store_id
        WHERE m.member_phone = ?
    ''');

    if (!includeDeleted) query.write(queryIsDeleted);

    final rows = await _db.rawQuery(
      query: query.toString(),
      arguments: [userPhone],
    );

    return rows.map(StoreModel.fromMap).toList();
  }

  @override
  Future<List<StoreMemberModel>> getMembers({
    required String storeId,
    bool includeDeleted = true,
  }) async {
    final filters = {
      'store_id': storeId,
      if (!includeDeleted) 'is_deleted': 0,
    };

    final rows = await _db.readRowsWhere(
      table: 'store_members',
      filters: filters,
    );

    return rows.map(StoreMemberModel.fromMap).toList();
  }

  @override
  Future<void> insertStoreMember(
    StoreMemberModel member, [
    bool skipLocalTracking = false,
  ]) async {
    await _db.insertRow(
      table: 'store_members',
      map: member.toMap(),
    );

    await _updateStore(member.storeId);

    if (skipLocalTracking) return;

    final memberKey = StoreMemberKey(
      storeId: member.storeId,
      memberPhone: member.memberPhone,
    );

    final change = SyncChangeModel(
      tableName: 'store_members',
      recordId: memberKey.toJson(),
      operation: SyncOperation.insert,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }

  @override
  Future<void> deleteStoreMember({
    required StoreMemberKey key,
    bool skipLocalTracking = false,
  }) async {
    await _db.update(
      table: 'store_members',
      filterWhere: key.toMap(),
      updated: {
        'is_deleted': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
    );

    if (skipLocalTracking) return;

    final syncChange = SyncChangeModel(
      tableName: 'store_members',
      recordId: key.toJson(),
      operation: SyncOperation.delete,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(syncChange);

    await _updateStore(key.storeId);
  }

  @override
  Future<void> upsertStores(
    List<StoreModel> stores, [
    bool skipLocalTracking = false,
  ]) async {
    for (final store in stores) {
      final isFound = (await getStore(store.id!)) != null;

      if (isFound) {
        await updateStore(store, skipLocalTracking);
      } else {
        await addStore(store, skipLocalTracking);
      }
    }
  }

  @override
  Future<void> upsertMembers(
    List<StoreMemberModel> members, [
    bool skipLocalTracking = false,
  ]) async {
    for (final member in members) {
      final memberKey = StoreMemberKey(
        storeId: member.storeId,
        memberPhone: member.memberPhone,
      );
      final isFound = (await getStoreMember(memberKey)) != null;

      if (isFound) {
        await updateStoreMember(member, skipLocalTracking);
      } else {
        await insertStoreMember(member, isFound);
      }
    }
  }

  @override
  Future<void> updateStore(
    StoreModel store, [
    bool skipLocalTracking = false,
  ]) async {
    await _db.update(
      updated: store.toMap(),
      filterWhere: {'id': store.id},
      table: 'stores',
    );

    if (skipLocalTracking) return;

    final change = SyncChangeModel(
      tableName: 'stores',
      recordId: store.id!,
      operation: SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }

  @override
  Future<StoreModel?> getStore(String storeId) async {
    try {
      final row = await _db.readRow(id: storeId, column: 'id', table: 'stores');

      if (row.isEmpty) throw Exception();
      final model = StoreModel.fromMap(row);

      return model;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<StoreMemberModel?> getStoreMember(StoreMemberKey key) async {
    try {
      final rows = await _db.readWhereArguments(
        table: 'store_members',
        where: 'store_id = ? AND member_phone = ?',
        whereArgs: [key.storeId, key.memberPhone],
      );

      final model = StoreMemberModel.fromMap(rows.first);

      return model;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateStoreMember(
    StoreMemberModel member, [
    bool skipLocalTracking = false,
  ]) async {
    await _db.update(
      updated: member.toUpdateMap(),
      filterWhere: {
        'store_id': member.storeId,
        'member_phone': member.memberPhone,
      },
      table: 'store_members',
    );

    if (skipLocalTracking) return;

    final memberKey = StoreMemberKey(
      storeId: member.storeId,
      memberPhone: member.memberPhone,
    );
    final change = SyncChangeModel(
      tableName: 'store_members',
      recordId: memberKey.toJson(),
      operation: SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }

  @override
  Future<void> removeStore(
    String storeId, [
    bool skipLocalTracking = false,
  ]) async {
    await _db.update(
      table: 'stores',
      filterWhere: {'id': storeId},
      updated: {
        'is_deleted': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
    if (skipLocalTracking) return;

    final change = SyncChangeModel(
      tableName: 'stores',
      recordId: storeId,
      operation: SyncOperation.delete,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }
}
