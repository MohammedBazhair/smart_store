import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/admin_store_repository.dart';

final adminStoreRepositoryProvider = Provider<AdminStoreRepository>((ref) {
  return AdminStoreRepository(Supabase.instance.client);
});

final adminStoresListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.read(adminStoreRepositoryProvider);
  return repo.getAllStores();
});
