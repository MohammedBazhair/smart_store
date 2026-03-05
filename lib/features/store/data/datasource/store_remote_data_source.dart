import '../../../../core/database/remote/remote_database_service.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';



abstract class StoreRemoteDataSource {
  /// إنشاء متجر
  Future<void> createStore(StoreModel store);

  /// جلب جميع المتاجر الخاصة بالمستخدم
  Future<List<StoreModel>> getUserStores(String userPhone);

  /// جلب أعضاء متجر معين
  Future<List<StoreMemberModel>> getMembers(String storeId);

  /// إضافة عضو لمتجر
  Future<void> insertMember(StoreMemberModel member);

  /// حذف عضو من المتجر
  Future<void> deleteMember(String id);
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
  Future<void> deleteMember(String id) async {
    await _client.delete(table: 'store_members', id: id, column: 'member_id');
  }
}
