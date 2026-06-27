import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/remote/remote_database_service.dart';
import '../../../store/data/datasource/store_remote_data_source.dart';
import '../../../store/data/models/store_member_key.dart';
import '../../../store/data/models/store_member_model.dart';
import '../../../store/data/models/store_model.dart';
import '../../../store/domain/entities/store.dart';
import '../../../store/domain/entities/store_member.dart';
import '../../../user/domain/entities/role.dart';

class AdminStoreRepository {
  AdminStoreRepository(this._remoteDatabase, this._storeRemoteDataSource);

  final RemoteDatabaseService _remoteDatabase;
  final StoreRemoteDataSource _storeRemoteDataSource;

  Stream<Map<String, Store>> getAllStores() {
    final response =
        _remoteDatabase.readRowsRealTime(table: 'stores', primaryKey: ['id']);
    return response.map(
      (rows) {
        final entries = rows.map((map) {
          final store = StoreModel.fromMap(map);

          return MapEntry(store.id!, store);
        });

        return Map.fromEntries(entries);
      },
    );
  }

  Stream<List<StoreMember>> getAllMembers() {
    final response = _remoteDatabase.readRowsRealTime(
      table: 'store_members',
      primaryKey: ['store_id', 'member_phone'],
    );
    return response.map((m) => m.map(StoreMemberModel.fromMap).toList());
  }

  Future<void> deleteStore(String storeId) async {
    await _storeRemoteDataSource.removeStore(storeId);
  }

  Future<void> insertMember(StoreMemberKey primaryKey, Role role) async {
    final row = await _remoteDatabase.readRow(
      value: primaryKey.memberPhone,
      column: 'phone',
      selectColumns: ['phone'],
      table: AppConstants.profilesTable,
    );

    if (row.isEmpty) {
      throw Exception('صاحب الرقم غير موجود');
    }

    final member = StoreMemberModel(
      primaryKey: primaryKey,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _storeRemoteDataSource.addMember(member);
  }
}
