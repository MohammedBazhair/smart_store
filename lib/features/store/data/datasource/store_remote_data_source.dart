import '../../../../core/database/remote/remote_database_service.dart';
import '../../../../core/shared/data/models/sync_state_model.dart';
import '../models/store_member_key.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<void> addStore(StoreModel store);
  Future<void> updateStore(StoreModel store);
  Future<void> removeStore(String storeId);
  Future<void> insertStores(List<StoreModel> stores);
  Future<void> deleteStores(List<String> storesIds);
  Future<void> updateStores(List<StoreModel> stores);
  Future<List<StoreModel>> getUserStores({
    required String userPhone,
    bool includeDeleted = true,
    SyncStateModel? lastSynced,
  });

  Future<void> addMember(StoreMemberModel member);
  Future<void> updateMember(StoreMemberModel member);
  Future<void> removeMember(StoreMemberKey key);
  Future<void> insertMembers(List<StoreMemberModel> members);
  Future<void> updateStoreMembers(List<StoreMemberModel> members);
  Future<List<StoreMemberModel>> getMembers({
    required String storeId,
    bool includeDeleted = true,
    SyncStateModel? lastSynced,
  });
  Future<void> deleteMembers(List<StoreMemberKey> params);
  Future<List<StoreMemberModel>> getMembersForUser(
    String userPhone, [
    SyncStateModel? lastSynced,
  ]);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  StoreRemoteDataSourceImpl(this._client);

  final RemoteDatabaseService _client;

  @override
  Future<void> addStore(StoreModel store) async {
    await _client.insertRow(map: store.toMap(), table: 'stores');
  }

  @override
  Future<List<StoreModel>> getUserStores({
    required String userPhone,
    bool includeDeleted = true,
    SyncStateModel? lastSynced,
  }) async {
    final response = _client.client
        .from('stores')
        .select('*, store_members!inner(*)')
        .eq('store_members.member_phone', userPhone);

    final resultResponse =
        includeDeleted ? response : response.eq('is_deleted', 0);

    final lastSyncedDate = lastSynced?.lastSynced.toIso8601String();
    final result = await (lastSyncedDate != null
        ? resultResponse.gte('updated_at', lastSyncedDate)
        : resultResponse.order('created_at', ascending: true));

    return result.map(StoreModel.fromMap).toList();
  }

  @override
  Future<List<StoreMemberModel>> getMembers({
    required String storeId,
    bool includeDeleted = true,
    SyncStateModel? lastSynced,
  }) async {
    final response =
        _client.client.from('store_members').select().eq('store_id', storeId);

    final resultResponse =
        includeDeleted ? response : response.eq('is_deleted', 0);

    final lastSyncedDate = lastSynced?.lastSynced.toIso8601String();

    final result = await (lastSyncedDate != null
        ? resultResponse.gte('updated_at', lastSyncedDate)
        : resultResponse);

    return result.map(StoreMemberModel.fromMap).toList();
  }

  @override
  Future<void> addMember(StoreMemberModel member) async {
    await _client.insertRow(table: 'store_members', map: member.toMap());

    await _updateStore(member.primaryKey.storeId);
  }

  @override
  Future<void> removeMember(StoreMemberKey key) async {
    await _client.update(
      updated: {
        'is_deleted': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      table: 'store_members',
      whereFilter: key.toMap(),
    );

    await _client.update(
      updated: {'updated_at': DateTime.now().toUtc().toIso8601String()},
      table: 'stores',
      whereFilter: {'store_id': key.storeId},
    );
  }

  @override
  Future<void> updateStore(StoreModel store) async {
    await _client.update(
      updated: store.toMap(),
      whereFilter: {
        'id': store.id!,
      },
      table: 'stores',
    );
  }

  @override
  Future<void> updateMember(StoreMemberModel member) async {
    await _client.update(
      updated: member.toUpdateMap(),
      table: 'store_members',
      whereFilter:member.primaryKey.toMap(),
    );

    await _updateStore(member.primaryKey.storeId);
  }

  Future<void> _updateStore(String storeId) async {
    await _client.update(
      updated: {'updated_at': DateTime.now().toUtc().toIso8601String()},
      table: 'stores',
      whereFilter: {'id': storeId},
    );
  }

  @override
  Future<void> removeStore(String storeId) {
    return _client.update(
      updated: {
        'is_deleted': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      whereFilter: {'id': storeId},
      table: 'stores',
    );
  }

  @override
  Future<void> insertMembers(List<StoreMemberModel> members) async {
    final rows = members.map((m) => m.toMap()).toList();
    await _client.insertRows(rows: rows, table: 'store_members');
  }

  @override
  Future<void> updateStoreMembers(List<StoreMemberModel> members) async {
    final rows = members.map((m) => m.toMap()).toList();
    await _client.updateRows(
      rows: rows,
      table: 'store_members',
      onConflict: 'store_id,member_phone',
    );
  }

  @override
  Future<void> deleteMembers(List<StoreMemberKey> params) async {
    final futures = params.map(removeMember);
    await Future.wait(futures);
  }

  @override
  Future<void> insertStores(List<StoreModel> stores) async {
    final rows = stores.map((m) => m.toMap()).toList();
    await _client.insertRows(rows: rows, table: 'stores');
  }

  @override
  Future<void> updateStores(List<StoreModel> stores) async {
    final rows = stores.map((m) => m.toMap()).toList();
    await _client.updateRows(
      rows: rows,
      table: 'stores',
      onConflict: 'id',
    );
  }

  @override
  Future<void> deleteStores(List<String> storesIds) async {
    final futures = storesIds.map(removeStore);

    await Future.wait(futures);
  }

  @override
  Future<List<StoreMemberModel>> getMembersForUser(
    String userPhone, [
    SyncStateModel? lastSynced,
  ]) async {
    final response = _client.client
        .from('store_members')
        .select('*, stores!inner(id)')
        .eq('member_phone', userPhone);

    final lastSyncedDate = lastSynced?.lastSynced.toIso8601String();

    final result = await (lastSyncedDate != null
        ? response.gt('updated_at', lastSyncedDate)
        : response);

    return result.map(StoreMemberModel.fromMap).toList();
  }
}
