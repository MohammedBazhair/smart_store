import '../../../../core/database/remote/remote_database_service.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

class StoreRemoteDataSource {
  StoreRemoteDataSource(this._client);

  final RemoteDatabaseService _client;

  Future<void> createStore(StoreModel store) async {
    await _client.insertRow(map: store.toMap(), table: 'stores');
  }

  Future<List<StoreModel>> getUserStores(String userId) async {
    final result = await _client.client
        .from('stores')
        .select('*, store_members(*)')
        .contains('member_id', userId);

    return result.map(StoreModel.fromMap).toList();
  }

  Future<List<StoreMemberModel>> getMembers(String storeId) async {
    final result = await _client
        .readRowsWhere(table: 'store_members', filters: {'store_id': storeId});

    return result.map(StoreMemberModel.fromMap).toList();
  }

  Future<void> insertMember(StoreMemberModel member) async {
    await _client.insertRow(table: 'store_members', map: member.toMap());
  }

  Future<void> deleteMember(String id) async {
    await _client.delete(table: 'store_members', id: id, column: 'member_id');
  }
}
