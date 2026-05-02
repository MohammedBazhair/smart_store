import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../data/datasource/category_local_data_source.dart';
import '../../data/datasource/global_product_local_data_source.dart';
import '../../data/datasource/product_remote_data_source.dart';
import '../../data/datasource/product_search_local_data_source.dart';
import '../../data/datasource/store_product_local_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/search_product_repository_impl.dart';
import '../../data/repositories/sync_product_repository_impl.dart';
import '../../domain/entities/expiry_date.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/product_repository.dart';
import 'expiry_date_controller.dart';
import 'product_controller.dart';
import 'product_search_controller.dart';
import 'product_state.dart';

final storeProductLocalDataSourceProvider = Provider((ref) {
  final db = ref.read(localDatabaseServiceProvider);
  final _sync = ref.read(syncLocalDataSourceProvider);

  return StoreProductLocalDataSourceImpl(db, _sync);
});

final productSearchLocalDataSourceProvider = Provider((ref) {
  final db = ref.read(localDatabaseServiceProvider);

  return ProductSearchLocalDataSourceImpl(db);
});

final globalProductLocalDataSourceProvider = Provider((ref) {
  final db = ref.read(localDatabaseServiceProvider);
  final _sync = ref.read(syncLocalDataSourceProvider);

  return GlobalProductLocalDataSourceImpl(db, _sync);
});

final categoryLocalDataSourceProvider = Provider((ref) {
  final db = ref.read(localDatabaseServiceProvider);

  return CategoryLocalDataSourceImpl(db);
});

final searchProductRepositoryProvider = Provider((ref) {
  final _localSearch = ref.read(productSearchLocalDataSourceProvider);

  return SearchProductRepositoryImpl(_localSearch);
});

final _productRemoteDataSourceProvider = Provider((ref) {
  final _client = ref.read(remoteDatabaseServiceProvider);
  return ProductRemoteDataSourceImpl(_client);
});

final syncProductRepositoryProvider = Provider((ref) {
  final _remoteDatabase = ref.read(_productRemoteDataSourceProvider);
  final _localCache = ref.read(localCacheServiceProvider);
  final _connectivity = ref.read(networkProvider);
  final _sync = ref.read(syncLocalDataSourceProvider);
  final _localGlobalProductDb = ref.read(globalProductLocalDataSourceProvider);
  final _localCategoryDb = ref.read(categoryLocalDataSourceProvider);
  final _localStoreProductDb = ref.read(storeProductLocalDataSourceProvider);

  return SyncProductRepositoryImpl(
    _localCache,
    _sync,
    _connectivity,
    _localGlobalProductDb,
    _remoteDatabase,
    _localStoreProductDb,
    _localCategoryDb,
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final _remoteDatabase = ref.read(_productRemoteDataSourceProvider);
  final _localCache = ref.read(localCacheServiceProvider);
  final _connectivity = ref.read(networkProvider);
  final _sync = ref.read(syncLocalDataSourceProvider);
  final _localGlobalProductDb = ref.read(globalProductLocalDataSourceProvider);
  final _localCategoryDb = ref.read(categoryLocalDataSourceProvider);
  final _localStoreProductDb = ref.read(storeProductLocalDataSourceProvider);
  final _syncRepo = ref.read(syncProductRepositoryProvider);
  final _db = ref.read(localDatabaseServiceProvider);

  return ProductRepositoryImpl(
    _connectivity,
    _localCache,
    _localCategoryDb,
    _localGlobalProductDb,
    _localStoreProductDb,
    _remoteDatabase,
    _sync,
    _syncRepo,
    _db,
  );
});

final productQueryProvider = StateProvider.autoDispose<ProductQuery>(
  (ref) => const ProductQuery(),
);

final productSearchControllerProvider = AsyncNotifierProvider.autoDispose<
    ProductSearchController, List<StoreProduct>>(
  ProductSearchController.new,
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
