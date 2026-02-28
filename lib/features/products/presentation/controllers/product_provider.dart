import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/result.dart';
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

/// Provider للحصول على جميع المنتجات
final productsProvider = FutureProvider<List<StoreProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final storeId = ref.watch(storeControllerProvider).state.selectedStoreId!;
  final result = await repository.getAllProducts(storeId);

  return result;
});

final productQueryProvider = StateProvider.autoDispose<ProductQuery>(
  (ref) => ProductQuery(),
);

final searchFilterProductsProvider =
    FutureProvider.autoDispose<List<StoreProduct>>((ref) async {
  final query = ref.watch(productQueryProvider);
  if (!query.hasQuery) return [];

  final repository = ref.watch(productRepositoryProvider);
  final storeId = ref.watch(storeControllerProvider).state.selectedStoreId!;
  final products = query.isSearching
      ? await repository.searchProducts(storeId: storeId, query: query.search)
      : await repository.getAllProducts(storeId);

  if (!query.hasCategory) return products;

  return products
      .where((p) => p.globalProduct.category.id == query.category?.id)
      .toList();
});

/// Provider للمنتجات المنتهية
final expiredProductsProvider = FutureProvider<List<StoreProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final storeId = ref.watch(storeControllerProvider).state.selectedStoreId!;

  final result = await repository.getExpiredProducts(storeId);
  if (result is SuccessState<List<StoreProduct>>) {
    return result.data;
  }
  return [];
});

/// Provider للمنتجات القريبة من الانتهاء
final nearExpiryProductsProvider =
    FutureProvider<List<StoreProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final storeId = ref.watch(storeControllerProvider).state.selectedStoreId!;

  final result = await repository.getNearExpiryProducts(storeId, 30);
  if (result is SuccessState<List<StoreProduct>>) {
    return result.data;
  }
  return [];
});

final focusNodesProvider = Provider<Map<ProductDetailsType, FocusNode>>((ref) {
  final mapEntries =
      ProductDetailsType.values.map((t) => MapEntry(t, FocusNode()));

  final map = Map.fromEntries(mapEntries);

  ref.onDispose(map.values.map((f) => f.dispose()).toList);
  return map;
});

final currentProductProvider = StateProvider<StoreProduct?>((ref) => null);

final expiryDateControllerProvider =
    StateNotifierProvider<ExpiryDateController, ExpiryDatePicker>(
  (ref) => ExpiryDateController(),
);

final productByIdProvider = FutureProvider.family<StoreProduct?, String>(
  (ref, id) async {
    final result =
        await ref.watch(productRepositoryProvider).getProductById(id);
    if (result is SuccessState<StoreProduct>) return result.data;
    return null;
  },
);

/// Provider للـ ProductController
final productControllerProvider =
    NotifierProvider<ProductManagementController, ProductManagementState>(() {
  return ProductManagementController();
});
