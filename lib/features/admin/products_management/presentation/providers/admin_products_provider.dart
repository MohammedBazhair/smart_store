import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/admin_product_repository.dart';

final adminProductRepositoryProvider = Provider<AdminProductRepository>((ref) {
  return AdminProductRepository(Supabase.instance.client);
});

final adminProductsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(adminProductRepositoryProvider);
  return repo.getAllProducts();
});
