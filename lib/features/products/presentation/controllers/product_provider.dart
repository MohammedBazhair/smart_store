import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../data/datasource/product_local_data_source.dart';
import '../../data/datasource/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/expiry_date.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/product_repository.dart';
import 'expiry_date_controller.dart';
import 'product_controller.dart';
import 'product_search_controller.dart';
import 'product_state.dart';

final _productLocalDataSource = Provider((ref) {
  final db = ref.read(localDatabaseServiceProvider);
  final _sync = ref.read(syncLocalDataSourceProvider);

  return ProductLocalDataSourceImpl(db, _sync);
});

final _productRemoteDataSource = Provider((ref) {
  final _client = ref.read(remoteDatabaseServiceProvider);
  return ProductRemoteDataSourceImpl(_client);
});

/// Provider لمستودع المنتجات
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final _remote = ref.read(_productRemoteDataSource);
  final _local = ref.read(_productLocalDataSource);
  final cache = ref.read(localCacheServiceProvider);
  final _network = ref.read(networkProvider);
  final _sync = ref.read(syncLocalDataSourceProvider);

  return ProductRepositoryImpl(_local, _remote, _network, cache, _sync);
});

final productQueryProvider = StateProvider.autoDispose<ProductQuery>(
  (ref) => const ProductQuery(),
);

final productSearchProvider = AsyncNotifierProvider.autoDispose<
    ProductSearchNotifier, List<StoreProduct>>(
  ProductSearchNotifier.new,
);

final focusNodesProvider =
    Provider.autoDispose<Map<ProductDetailsType, FocusNode>>((ref) {
  final map = {for (var t in ProductDetailsType.values) t: FocusNode()};

  ref.onDispose(() {
    for (var f in map.values) {
      f.dispose();
    }
  });

  return map;
});

final currentProductProvider = FutureProvider<StoreProduct?>((ref) {
  final productId = ref.watch(currentProductIdProvider);
  if (productId == null) return null;

  return ref.watch(productByIdProvider(productId).future);
});

final currentProductIdProvider = StateProvider<String?>((ref) => null);

final expiryDateControllerProvider =
    StateNotifierProvider<ExpiryDateController, ExpiryDateState>(
  (ref) => ExpiryDateController(),
);

final productByIdProvider = FutureProvider.family<StoreProduct?, String>(
  (ref, id) async {
    final product =
        await ref.read(productControllerProvider.notifier).getProductById(id);
    return product;
  },
);

/// Provider للـ ProductController
final productControllerProvider =
    NotifierProvider<ProductManagementController, ProductManagementState>(() {
  return ProductManagementController();
});
