import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/shared/providers/core_providers.dart';
import '../../data/admin_product_repository.dart';

final adminProductRepositoryProvider = Provider<AdminProductRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AdminProductRepository(supabase.client);
});

final adminProductsListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.read(adminProductRepositoryProvider);
  return repo.getAllProducts();
});
