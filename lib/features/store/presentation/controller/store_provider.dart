import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/core_providers.dart';
import '../../data/datasource/store_local_data_source.dart';
import '../../data/datasource/store_remote_data_source.dart';
import '../../data/models/store_member_key.dart';
import '../../data/repositories/store_repository_impl.dart';
import '../../domain/repositories/store_repository.dart';
import 'store_controller.dart';
import 'store_state.dart';

final storeRemoteDataSourceProvider = Provider((ref) {
  final _clint = ref.read(remoteDatabaseServiceProvider);
  return StoreRemoteDataSourceImpl(_clint);
});

final storeLocalDataSourceProvider = Provider((ref) {
  final _clint = ref.read(localDatabaseServiceProvider);
  final syncLocal = ref.read(syncLocalDataSourceProvider);
  return StoreLocalDataSourceImpl(_clint, syncLocal);
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final remoteDataSource = ref.read(storeRemoteDataSourceProvider);
  final localDataSource = ref.read(storeLocalDataSourceProvider);
  final userRepository = ref.read(userRepositoryProvider);
  final connectivityService = ref.read(networkProvider);
  final syncLocal = ref.read(syncLocalDataSourceProvider);

  return StoreRepositoryImpl(
    localDataSource,
    remoteDataSource,
    userRepository,
    connectivityService,
    syncLocal,
  );
});

final storeControllerProvider =
    NotifierProvider<StoreController, StoreEventState>(StoreController.new);

final currentMemberProvider = Provider((ref) {
  try {
    final storeState = ref.watch(storeControllerProvider).state;
    final profile = ref.watch(userControllerProvider).entity.profile;

    final storeId = storeState.selectedStoreId;
    final phone = profile.phone;

    if (storeId == null || phone == null) return null;

    final store = storeState.myStores[storeId];
    if (store == null) return null;

    final memberKey = StoreMemberKey(
      storeId: storeId,
      memberPhone: phone,
    );

    return store.members.firstWhere((m) => m.primaryKey == memberKey);
  } catch (e) {
    return null;
  }
});
