import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/core_providers.dart';
import '../../data/datasource/store_local_data_source.dart';
import '../../data/datasource/store_remote_data_source.dart';
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
  return StoreLocalDataSourceImpl(_clint);
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final remoteDataSource = ref.read(storeRemoteDataSourceProvider);
  final localDataSource = ref.read(storeLocalDataSourceProvider);
  final userRepository = ref.read(userRepositoryProvider);
  final connectivityService = ref.read(networkProvider);
  return StoreRepositoryImpl(
    localDataSource,
    remoteDataSource,
    userRepository,
    connectivityService,
  );
});

final storeControllerProvider =
    NotifierProvider<StoreController, StoreEventState>(StoreController.new);
