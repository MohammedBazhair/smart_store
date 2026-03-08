import '../../../../core/database/remote/remote_database_service.dart';
import '../../../../core/shared/data/models/sync_state_model.dart';
import '../models/delete_members_params.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<void> createStore(StoreModel store);
  Future<void> updateStore(StoreModel store);

  Future<List<StoreModel>> getUserStores(
    String userPhone, [
    SyncStateModel? lastSync,
  ]);

  Future<List<StoreMemberModel>> getMembers(
    String storeId, [
    SyncStateModel? lastSync,
  ]);

  Future<void> insertMember(StoreMemberModel member);

  Future<void> insertMembers(List<StoreMemberModel> members);
  Future<void> insertStores(List<StoreModel> stores);

  Future<void> deleteMember({
    required String memberPhone,
    required String storeId,
  });
  Future<void> deleteMembers(List<DeleteMembersParams> params);

  Future<void> deleteStore(String storeId);
  Future<void> deleteStores(List<String> storesIds);

  Future<void> updateStoreMember(StoreMemberModel member);
  Future<void> updateStoreMembers(List<StoreMemberModel> members);
  Future<void> updateStores(List<StoreModel> stores);

  Future<List<StoreMemberModel>> getMembersForUser(
    String userPhone, [
    SyncStateModel? lastSync,
  ]);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  StoreRemoteDataSourceImpl(this._client);

  final RemoteDatabaseService _client;

  @override
  Future<void> createStore(StoreModel store) async {
    await _client.insertRow(map: store.toMap(), table: 'stores');
  }

  @override
  Future<List<StoreModel>> getUserStores(
    String userPhone, [
    SyncStateModel? lastSync,
  ]) async {
    final response = _client.client
        .from('stores')
        .select('*, store_members!inner(*)')
        .eq('store_members.member_phone', userPhone);

    final lastSyncDate = lastSync?.lastSync.toIso8601String();
    final result = await (lastSyncDate != null
        ? response.gt('updated_at', lastSyncDate)
        : response.order('created_at', ascending: true));

    return result.map(StoreModel.fromMap).toList();
  }

  @override
  Future<List<StoreMemberModel>> getMembers(
    String storeId, [
    SyncStateModel? lastSync,
  ]) async {
    final response =
        _client.client.from('store_members').select().eq('store_id', storeId);

    final lastSyncDate = lastSync?.lastSync.toIso8601String();

    final result = await (lastSyncDate != null
        ? response.gt('updated_at', lastSyncDate)
        : response);

    return result.map(StoreMemberModel.fromMap).toList();
  }

  @override
  Future<void> insertMember(StoreMemberModel member) async {
    await _client.insertRow(table: 'store_members', map: member.toMap());

    await _updateStore(member.storeId);
     }

  @override
  Future<void> deleteMember({
    required String memberPhone,
    required String storeId,
  }) async {
    await _client.update(
      updated: {
        'is_deleted': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      table: 'store_members',
      whereFilter: {'member_phone': memberPhone, 'store_id': storeId},
    );

    await _client.update(
      updated: {'updated_at': DateTime.now().toUtc().toIso8601String()},
      table: 'stores',
      whereFilter: {'store_id': storeId},
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
  Future<void> updateStoreMember(StoreMemberModel member) async {
    await _client.update(
      updated: member.toUpdateMap(),
      table: 'store_members',
      whereFilter: {
        'store_id': member.storeId,
        'member_phone': member.memberPhone,
      },
    );

    await _updateStore(member.storeId);
  }

  Future<void> _updateStore(String storeId) async {
    await _client.update(
      updated: {'updated_at': DateTime.now().toUtc().toIso8601String()},
      table: 'stores',
      whereFilter: {'id': storeId},
    );
  }

  @override
  Future<void> deleteStore(String storeId) {
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
  Future<void> deleteMembers(List<DeleteMembersParams> params) async {
    final futures = params.map(
      (m) => deleteMember(memberPhone: m.memberPhone, storeId: m.storeId),
    );
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
    final futures = storesIds.map(deleteStore);

    await Future.wait(futures);
  }
  
 @override
  Future<List<StoreMemberModel>> getMembersForUser(
    String userPhone, [
    SyncStateModel? lastSync,
  ]) async {
    final response = _client.client
        .from('store_members')
        .select('*, stores!inner(id)')
        .eq('member_phone', userPhone);

    final lastSyncDate = lastSync?.lastSync.toIso8601String();

    final result = await (lastSyncDate != null
        ? response.gt('updated_at', lastSyncDate)
        : response);

    return result.map(StoreMemberModel.fromMap).toList();
  }
}
