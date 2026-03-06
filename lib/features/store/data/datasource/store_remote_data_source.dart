import '../../../../core/database/remote/remote_database_service.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<void> createStore(StoreModel store);

  Future<List<StoreModel>> getUserStores(String userPhone);

  Future<List<StoreMemberModel>> getMembers(String storeId);

  Future<void> insertMember(StoreMemberModel member);

  Future<void> deleteMember({
    required String memberPhone,
    required String storeId,
  });
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  StoreRemoteDataSourceImpl(this._client);

  final RemoteDatabaseService _client;

  @override
  Future<void> createStore(StoreModel store) async {
    await _client.insertRow(map: store.toMap(), table: 'stores');
  }

  @override
  Future<List<StoreModel>> getUserStores(String userPhone) async {
    final result = await _client.client
        .from('stores')
        .select('*, store_members!inner(*)')
        .eq('store_members.member_phone', userPhone);

    return result.map(StoreModel.fromMap).toList();
  }

  @override
  Future<List<StoreMemberModel>> getMembers(String storeId) async {
    final result = await _client
        .readRowsWhere(table: 'store_members', filters: {'store_id': storeId});

    return result.map(StoreMemberModel.fromMap).toList();
  }

  @override
  Future<void> insertMember(StoreMemberModel member) async {
    await _client.insertRow(table: 'store_members', map: member.toMap());
  }

  @override
  Future<void> deleteMember({
    required String memberPhone,
    required String storeId,
  }) async {
    await _client.deleteWhere(
      table: 'store_members',
      filters: {'member_phone': memberPhone, 'store_id': storeId},
    );
  }
}
