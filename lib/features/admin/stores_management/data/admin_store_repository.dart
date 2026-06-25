import '../../../../core/database/remote/remote_database_service.dart';
import '../../../store/data/datasource/store_remote_data_source.dart';
import '../../../store/data/models/store_member_key.dart';
import '../../../store/data/models/store_member_model.dart';
import '../../../store/data/models/store_model.dart';
import '../../../store/domain/entities/store.dart';
import '../../../user/domain/entities/role.dart';

class AdminStoreRepository {
  AdminStoreRepository(this._remoteDatabase, this._storeRemoteDataSource);

  final RemoteDatabaseService _remoteDatabase;
  final StoreRemoteDataSource _storeRemoteDataSource;

  Stream<List<Store>> getAllStores() {
    final response =
        _remoteDatabase.readRowsRealTime(table: 'stores', primaryKey: ['id']);
    return response.map((m) => m.map(StoreModel.fromMap).toList());
  }

  Future<void> deleteStore(String storeId) async {
    await _storeRemoteDataSource.removeStore(storeId);
  }

  Future<void> insertMember(StoreMemberKey primaryKey, Role role) async {
    final member = StoreMemberModel(
      primaryKey: primaryKey,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _storeRemoteDataSource.addMember(member);
  }
}
