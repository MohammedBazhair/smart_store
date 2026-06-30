import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/providers/core_providers.dart';
import '../../../../store/presentation/controller/store_provider.dart';
import '../../data/admin_store_repository.dart';
import '../controllers/admin_stores_controller.dart';
import '../controllers/admin_stores_state.dart';

final adminStoreRepositoryProvider = Provider<AdminStoreRepository>((ref) {
  final _remoteDatabase = ref.read(remoteDatabaseServiceProvider);
  final _storeRemoteDataSource = ref.read(storeRemoteDataSourceProvider);
  return AdminStoreRepository(_remoteDatabase, _storeRemoteDataSource);
});

final adminStoresControllerProvider =
    NotifierProvider<AdminStoresController, AdminStoresState>(
  AdminStoresController.new,
);
