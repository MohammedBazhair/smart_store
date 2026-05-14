import 'package:uuid/uuid.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
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
import '../models/store_member_key.dart';
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
      await remote.addStore(model);

      await local.addStore(model, true);
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
   Logger.debugLog(message: 'before hasConnection');

    final hasConnection = await connectivityService.hasConnection();
Logger.debugLog(message: 'after hasConnection');
    final stores = hasConnection
        ? await remote.getUserStores(
            userPhone: userPhone,
            includeDeleted: false,
          )
        : await local.getUserStores(
            userPhone: userPhone,
            includeDeleted: false,
          );

    if (hasConnection) await local.upsertStores(stores, hasConnection);

    return stores;
  }

  @override
  Future<Set<StoreMember>> getStoreMembers(String storeId) async {
    final hasConnection = await connectivityService.hasConnection();
    final members = hasConnection
        ? await remote.getMembers(storeId: storeId, includeDeleted: false)
        : await local.getMembers(storeId: storeId, includeDeleted: false);

    if (hasConnection) await local.upsertMembers(members, hasConnection);

    return members.toSet();
  }

  @override
  Future<void> addStoreMember(StoreMember member) async {
    if (!await connectivityService.hasConnection()) {
      throw const InternetException();
    }
    final isUserExist =
        await userRepository.isPhoneSignUp(member.primaryKey.memberPhone);

    if (!isUserExist) {
      throw const UserPhoneNotFoundException(
        'رقم هاتف العضو غير مسجل في التطبيق',
      );
    }

    final model = StoreMemberModel.fromEntity(member);

    if (!await connectivityService.hasConnection()) {
      throw const InternetException();
    }

    await Future.wait([
      remote.addMember(model),
      local.insertStoreMember(model),
    ]);
  }

  @override
  Future<void> removeStoreMember(StoreMemberKey key) async {
    final hasConnection = await connectivityService.hasConnection();

    if (hasConnection) {
      await remote.removeMember(key);
    }

    await local.deleteStoreMember(key: key, skipLocalTracking: hasConnection);
  }

  @override
  Future<void> updateStore(Store store) async {
    final updatedStore = store.copyWith(updatedAt: DateTime.now().toUtc());
    final storeModel = StoreModel.fromEntity(updatedStore);

    final hasConnection = await connectivityService.hasConnection();
    if (hasConnection) await remote.updateStore(storeModel);

    await local.updateStore(storeModel, hasConnection);
  }

  Future<void> _pushStoresChanges() async {
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

  Future<void> _pushMembersChanges() async {
    final membersChanges = await syncLocal.getTableChanges('store_members');

    final inserts = <StoreMemberModel>[];
    final updates = <StoreMemberModel>[];
    final deletes = <StoreMemberKey>[];

    for (final change in membersChanges) {
      final memberKey = StoreMemberKey.fromJson(change.recordId);
      switch (change.operation) {
        case SyncOperation.delete:
          deletes.add(memberKey);

        case SyncOperation.update:
          final member = await local.getStoreMember(memberKey);
          if (member != null) updates.add(member);
        case SyncOperation.insert:
          final member = await local.getStoreMember(memberKey);
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
    await _pushStoresChanges();
    await _pushMembersChanges();

    final lastSyncedStores = await syncLocal.getLastSynced('stores');
    final lastSyncedMembers = await syncLocal.getLastSynced('store_members');

    final stores = await remote.getUserStores(
      userPhone: userPhone,
      lastSynced: lastSyncedStores,
    );

    await local.upsertStores(stores, true);

    final members =
        await remote.getMembersForUser(userPhone, lastSyncedMembers);
    await local.upsertMembers(members, true);

    final storesSyncState =
        SyncStateModel(tableName: 'stores', lastSynced: DateTime.now().toUtc());
    final membersSyncState = SyncStateModel(
      tableName: 'store_members',
      lastSynced: DateTime.now().toUtc(),
    );

    await syncLocal.saveLastSynced(storesSyncState);
    await syncLocal.saveLastSynced(membersSyncState);
  }

  @override
  Future<void> deleteStore(String storeId) async {
    final hasConnection = await connectivityService.hasConnection();
    if (hasConnection) await remote.removeStore(storeId);

    await local.removeStore(storeId, hasConnection);
  }
}
