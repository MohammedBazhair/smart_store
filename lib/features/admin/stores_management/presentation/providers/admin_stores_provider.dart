import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/providers/core_providers.dart';
import '../../../../store/domain/entities/store.dart';
import '../../data/admin_store_repository.dart';

final adminStoreRepositoryProvider = Provider<AdminStoreRepository>((ref) {
  final _remoteDatabase = ref.read(remoteDatabaseServiceProvider);
  return AdminStoreRepository(_remoteDatabase);
});

final adminStoresListProvider =
    StreamProvider<List<Store>>((ref) {
  final repo = ref.read(adminStoreRepositoryProvider);
  return repo.getAllStores();
});
