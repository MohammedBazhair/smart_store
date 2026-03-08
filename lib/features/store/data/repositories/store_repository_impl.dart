import 'package:uuid/uuid.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/data/models/sync_state_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../../../errors/exceptions.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasource/store_local_data_source.dart';
import '../datasource/store_remote_data_source.dart';
import '../models/delete_members_params.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl(
    this.local,
    this.remote,
    this.userRepository,
    this.connectivityService,
    this.syncLocal,
  );
  final StoreRemoteDataSource remote;
  final StoreLocalDataSource local;
  final UserRepository userRepository;
  final ConnectivityService connectivityService;
  final SyncLocalDataSource syncLocal;

  @override
  Future<Store> createStore(Store store) async {
    try {
      if (!await connectivityService.hasConnection()) {
        throw const InternetException();
      }

      final newStore = store.copyWith(id: const Uuid().v4());
      final model = StoreModel.fromEntity(newStore);
      await remote.createStore(model);

      await local.createStore(model,true);
      return newStore;
    } catch (e) {
      if (e.toString().contains('enough credits')) {
        throw const CreditsZeroException(
          'يجب ان يكون معك عملة واحدة على الاقل لانشاء متجر',
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<Store>> getUserStores(String userPhone) async {
    final hasConnection = await connectivityService.hasConnection();

    final stores = hasConnection
        ? await remote.getUserStores(userPhone)
        : await local.getUserStores(userPhone);

    if (hasConnection) await local.setUserStores(stores);

    return stores;
  }

  @override
  Future<Set<StoreMember>> getStoreMembers(String storeId) async {
    final hasConnection = await connectivityService.hasConnection();
    final members = hasConnection
        ? await remote.getMembers(storeId)
        : await local.getMembers(storeId);

    if (hasConnection) await local.setMembers(members);

    return members.toSet();
  }

  @override
  Future<void> addStoreMember(StoreMember member) async {
    if (!await connectivityService.hasConnection()) {
      throw const InternetException();
    }
    final isUserExist = await userRepository.isPhoneSignUp(member.memberPhone);

    if (!isUserExist) {
      throw const UserPhoneNotFoundException(
        'رقم هاتف العضو غير مسجل في التطبيق',
      );
    }

    final model = StoreMemberModel.fromEntity(member);

    await remote.insertMember(model);
    await local.insertStoreMember(model);
  }

  @override
  Future<void> removeStoreMember({
    required String memberPhone,
    required String storeId,
  }) async {
    final hasConnection = await connectivityService.hasConnection();

    if (hasConnection) {
      await remote.deleteMember(memberPhone: memberPhone, storeId: storeId);
    }

    await local.deleteStoreMember(memberPhone: memberPhone, storeId: storeId,isSync: hasConnection);
  }

  @override
  Future<void> updateStore(Store store) async {
    final updatedStore = store.copyWith(updatedAt: DateTime.now());
    final storeModel = StoreModel.fromEntity(updatedStore);

    final hasConnection = await connectivityService.hasConnection();
    if (hasConnection) await remote.updateStore(storeModel);

    await local.updateStore(storeModel, hasConnection);
  }

  @override
  Future<void> pushStoresChanges() async {
    final storesChanges = await syncLocal.getTableChanges('stores');

    final inserts = <StoreModel>[];
    final updates = <StoreModel>[];
    final deletes = <String>[];

    for (final change in storesChanges) {
      switch (change.operation) {
        case SyncOperation.delete:
          deletes.add(change.recordId);
        case SyncOperation.update:
          final store = await local.getStore(change.recordId);
          if (store != null) updates.add(store);

        case SyncOperation.insert:
          final store = await local.getStore(change.recordId);
          if (store != null) inserts.add(store);
      }
    }

    if (inserts.isNotEmpty) {
      await remote.insertStores(inserts);
    }

    if (updates.isNotEmpty) {
      await remote.updateStores(updates);
    }

    if (deletes.isNotEmpty) {
      await remote.deleteStores(deletes);
    }

    await syncLocal.clearTablesChanges('stores');
  }

  @override
  Future<void> pushMembersChanges() async {
    final membersChanges = await syncLocal.getTableChanges('store_members');

    final inserts = <StoreMemberModel>[];
    final updates = <StoreMemberModel>[];
    final deletes = <DeleteMembersParams>[];

    for (final change in membersChanges) {
      final ids = change.recordId.split('|');
      final storeId = ids[0];
      final memberPhone = ids[1];

      switch (change.operation) {
        case SyncOperation.delete:
          deletes.add(
            DeleteMembersParams(storeId: storeId, memberPhone: memberPhone),
          );

        case SyncOperation.update:
          final member = await local.getStoreMember(
            storeId: storeId,
            memberPhone: memberPhone,
          );
          if (member != null) updates.add(member);
        case SyncOperation.insert:
          final member = await local.getStoreMember(
            storeId: storeId,
            memberPhone: memberPhone,
          );
          if (member != null) inserts.add(member);
      }
    }

    if (inserts.isNotEmpty) {
      await remote.insertMembers(inserts);
    }
    if (updates.isNotEmpty) {
      await remote.updateStoreMembers(updates);
    }
    if (deletes.isNotEmpty) {
      await remote.deleteMembers(deletes);
    }

    await syncLocal.clearTablesChanges('store_members');
  }

  @override
  Future<void> syncAll(String userPhone) async {
    await pushStoresChanges();
    await pushMembersChanges();

    final lastSyncStores = await syncLocal.getLastSync('stores');
    final lastSyncMembers = await syncLocal.getLastSync('store_members');

    final stores = await remote.getUserStores(userPhone, lastSyncStores);
    await local.setUserStores(stores);

    final members = await remote.getMembersForUser(userPhone, lastSyncMembers);
    await local.setMembers(members);

    final storesSyncState =
        SyncStateModel(tableName: 'stores', lastSync: DateTime.now());
    final membersSyncState =
        SyncStateModel(tableName: 'store_members', lastSync: DateTime.now());

    await syncLocal.saveLastSync(storesSyncState);
    await syncLocal.saveLastSync(membersSyncState);
  }

  @override
  Future<void> deleteStore(String storeId) async {
    final hasConnection = await connectivityService.hasConnection();
    if (hasConnection) await remote.deleteStore(storeId);

    await local.deleteStore(storeId, hasConnection);
  }
}
