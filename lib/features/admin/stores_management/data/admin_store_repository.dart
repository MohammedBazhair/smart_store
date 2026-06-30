import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/remote/remote_database_service.dart';
import '../../../store/data/datasource/store_remote_data_source.dart';
import '../../../store/data/models/store_member_key.dart';
import '../../../store/data/models/store_member_model.dart';
import '../../../store/data/models/store_model.dart';
import '../../../store/domain/entities/store_member.dart';
import '../../../store/presentation/controller/store_state.dart';
import '../../../user/domain/entities/role.dart';
import '../domain/entities/user_search_result.dart';

class AdminStoreRepository {
  AdminStoreRepository(this._remoteDatabase, this._storeRemoteDataSource);

  final RemoteDatabaseService _remoteDatabase;
  final StoreRemoteDataSource _storeRemoteDataSource;

  Future<Map<String, StoreWithMembers>> getStoresWithMembers() async {
    final response = await _remoteDatabase.readRows(table: 'stores');

    final storeMembers = await _getAllMembers();

    final result = <String, StoreWithMembers>{};

    await Future.wait(
      response.map(
        (map) async {
          final store = StoreModel.fromMap(map);
          final storeFull = StoreWithMembers(
            store: store,
            members: storeMembers[store.id!] ?? {},
          );
          result[store.id!] = storeFull;
        },
      ),
    );

    return result;
  }

  Future<Map<String, Set<StoreMember>>> _getAllMembers() async {
    final response = await _remoteDatabase.readRows(
      table: 'store_members',
    );

    final result = <String, Set<StoreMember>>{};

    await Future.wait(
      response.map((map) async {
        final member = StoreMemberModel.fromMap(map);

        result.update(
          member.primaryKey.storeId,
          (members) {
            return {...members, member};
          },
          ifAbsent: () => {member},
        );
      }),
    );

    return result;
  }

  Future<void> deleteStore(String storeId) async {
    await _storeRemoteDataSource.removeStore(storeId);
  }

  Future<StoreMember> insertMember(StoreMemberKey primaryKey, Role role) async {
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
    return member;
  }

  Future<List<UserSearchResult>> searchUsers(String queryPhone) async {
    final rows = await _remoteDatabase.searchByQuery(
      table: AppConstants.profilesTable,
      column: 'phone',
      query: queryPhone,
      columnsSelect: UserSearchResult.dbColumns,
    );

    return rows.map(UserSearchResult.fromMap).toList();
  }
}
