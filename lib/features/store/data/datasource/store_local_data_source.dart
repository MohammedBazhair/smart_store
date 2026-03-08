import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/shared/data/models/sync_change_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../../user/domain/entities/role.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

abstract class StoreLocalDataSource {
  Future<void> createStore(StoreModel store, [bool isSync = false]);
  Future<StoreModel?> getStore(String storeId);
  Future<void> updateStore(StoreModel store, [bool isSync = false]);

  Future<List<StoreModel>> getUserStores(String userPhone);
  Future<void> setUserStores(List<StoreModel> stores);

  Future<List<StoreMemberModel>> getMembers(String storeId);
  Future<void> setMembers(List<StoreMemberModel> members);

  Future<void> insertStoreMember(
    StoreMemberModel member, [
    bool isSync = false,
  ]);
  Future<void> updateStoreMember(
    StoreMemberModel member, [
    bool isSync = false,
  ]);
  Future<StoreMemberModel?> getStoreMember({
    required String storeId,
    required String memberPhone,
  });

  Future<void> deleteStoreMember({
    required String memberPhone,
    required String storeId,
    bool isSync = false,
  });

  Future<void> deleteStore(String storeId, [bool isSync = false]);
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
  Future<void> createStore(StoreModel store, [bool isSync = false]) async {
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

      if (isSync) return;

      final storeChange = SyncChangeModel(
        tableName: 'stores',
        recordId: store.id!,
        operation: SyncOperation.insert,
        updatedAt: DateTime.now().toUtc(),
      );
      await _sync.addChange(storeChange);

      final memberChange = SyncChangeModel(
        tableName: 'store_members',
        recordId: '${store.id!}|${member.memberPhone}',
        operation: SyncOperation.insert,
        updatedAt: DateTime.now().toUtc(),
      );
      await _sync.addChange(memberChange);
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }

  @override
  Future<List<StoreModel>> getUserStores(String userPhone) async {
    final rows = await _db.rawQuery(
      query: '''
        SELECT s.*
        FROM stores s
        JOIN store_members m
        ON s.id = m.store_id
        WHERE m.member_phone = ?
        AND s.is_deleted = 0
        AND m.is_deleted = 0
    ''',
      arguments: [userPhone],
    );

    return rows.map(StoreModel.fromMap).toList();
  }

  @override
  Future<List<StoreMemberModel>> getMembers(String storeId) async {
    final result = await _db.readRowsWhere(
      table: 'store_members',
      filters: {'store_id': storeId},
    );

    return result.map(StoreMemberModel.fromMap).toList();
  }

  @override
  Future<void> insertStoreMember(
    StoreMemberModel member, [
    bool isSync = false,
  ]) async {
    await _db.insertRow(
      table: 'store_members',
      map: member.toMap(),
    );

    await _updateStore(member.storeId);

    if (isSync) return;

    final change = SyncChangeModel(
      tableName: 'store_members',
      recordId: '${member.storeId}|${member.memberPhone}',
      operation: SyncOperation.insert,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }

  @override
  Future<void> deleteStoreMember({
    required String memberPhone,
    required String storeId,
    bool isSync = false,
  }) async {
    await _db.update(
      table: 'store_members',
      filterWhere: {'member_phone': memberPhone, 'store_id': storeId},
      updated: {
        'is_deleted': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
    );

    if (isSync) return;

    final syncChange = SyncChangeModel(
      tableName: 'store_members',
      recordId: '$storeId|$memberPhone',
      operation: SyncOperation.delete,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(syncChange);

    await _updateStore(storeId);
  }

  @override
  Future<void> setUserStores(
    List<StoreModel> stores, [
    bool fromServer = false,
  ]) async {
    for (final store in stores) {
      final isFound = (await getStore(store.id!)) != null;

      if (isFound) {
        await updateStore(store);
      } else {
        await createStore(store);
      }
    }
  }

  @override
  Future<void> setMembers(List<StoreMemberModel> members) async {
    for (final member in members) {
      final isFound = (await getStoreMember(
            storeId: member.storeId,
            memberPhone: member.memberPhone,
          )) !=
          null;

      if (isFound) {
        await updateStoreMember(member);
      } else {
        await insertStoreMember(member);
      }
    }
  }

  @override
  Future<void> updateStore(
    StoreModel store, [
    bool isSync = false,
  ]) async {
    await _db.update(
      updated: store.toMap(),
      filterWhere: {'id': store.id},
      table: 'stores',
    );

    if (isSync) return;

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
  Future<StoreMemberModel?> getStoreMember({
    required String storeId,
    required String memberPhone,
  }) async {
    try {
      final rows = await _db.readWhereArguments(
        table: 'store_members',
        where: 'store_id = ? AND member_phone = ?',
        whereArgs: [storeId, memberPhone],
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
    bool isSync = false,
  ]) async {
    await _db.update(
      updated: member.toUpdateMap(),
      filterWhere: {
        'store_id': member.storeId,
        'member_phone': member.memberPhone,
      },
      table: 'store_members',
    );

    if (isSync) return;

    final change = SyncChangeModel(
      tableName: 'store_members',
      recordId: '${member.storeId}|${member.memberPhone}',
      operation: SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }

  @override
  Future<void> deleteStore(String storeId, [bool isSync = false]) async {
    await _db.update(
      table: 'stores',
      filterWhere: {'id': storeId},
      updated: {
        'is_deleted': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
    if (isSync) return;

    final change = SyncChangeModel(
      tableName: 'stores',
      recordId: storeId,
      operation: SyncOperation.delete,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sync.addChange(change);
  }
}
