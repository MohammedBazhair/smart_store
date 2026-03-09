import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/log.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../data/datasource/product_local_data_source.dart';
import '../../data/datasource/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/expiry_date_picker.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/product_repository.dart';
import 'expiry_date_controller.dart';
import 'product_controller.dart';
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

final searchFilterProductsProvider =
    FutureProvider.autoDispose<List<StoreProduct>>((ref) async {
  final query = ref.watch(productQueryProvider);
  if (!query.hasQuery) return [];

  Logger.debugLog(message: query.isSearching.toString());
  final controller = ref.read(productControllerProvider.notifier);
  final products = query.isSearching
      ? await controller.searchProducts(query)
      : <StoreProduct>[];

  return products;
});

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
final currentProductProvider = StateProvider<StoreProduct?>((ref) => null);

final expiryDateControllerProvider =
    StateNotifierProvider<ExpiryDateController, ExpiryDatePicker>(
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

final initializeDashboardProvider = FutureProvider((ref) async {
  final controller = ref.read(productControllerProvider.notifier);
  await controller.initialize();
  await ref.read(alertControllerProvider.notifier).loadAlerts();
});
