import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/shared/providers/core_providers.dart';
import '../../../store/presentation/controller/store_provider.dart';
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
  return ProductLocalDataSourceImpl(db);
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
  return ProductRepositoryImpl(_local, _remote, _network, cache);
});


final productQueryProvider = StateProvider.autoDispose<ProductQuery>(
  (ref) => ProductQuery(),
);

final searchFilterProductsProvider =
    FutureProvider.autoDispose<List<StoreProduct>>((ref) async {
  final query = ref.read(productQueryProvider);
  if (!query.hasQuery) return [];

  final repository = ref.read(productRepositoryProvider);
  final storeId = ref.watch(storeControllerProvider).state.selectedStoreId!;
  final products = query.isSearching
      ? await repository.searchProducts(storeId: storeId, query: query.search)
      : (await repository.getStoreProducts(storeId)).values.toList();

  if (!query.hasCategory) return products;

  return products
      .where((p) => p.globalProduct.category.id == query.category?.id)
      .toList();
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
