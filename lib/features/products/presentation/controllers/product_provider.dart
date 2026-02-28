import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/core_providers.dart';
import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../errors/result.dart';
import '../../data/datasource/product_local_data_source.dart';
import '../../data/datasource/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/expiry_date_picker.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/seller_product.dart';
import '../../domain/repositories/product_repository.dart';
import 'expiry_date_controller.dart';

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
  final _network = ref.read(networkProvider);
  return ProductRepositoryImpl(_local, _remote, _network);
});

/// Provider للحصول على جميع المنتجات
final productsProvider = FutureProvider<List<SellerProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getAllProducts(sellerId);

  return result;
});

final productQueryProvider = StateProvider.autoDispose<ProductQuery>(
  (ref) => ProductQuery(),
);

final searchFilterProductsProvider =
    FutureProvider.autoDispose<List<SellerProduct>>((ref) async {
  final query = ref.watch(productQueryProvider);
  if (!query.hasQuery) return [];

  final repository = ref.watch(productRepositoryProvider);

  final products = query.isSearching
      ? await repository.searchProducts( sellerId: , query:  query.search):
     await repository.getAllProducts(sellerId);

  if (!query.hasCategory) return products;

  return products.where((p) => p.globalProduct.category.id == query.category?.id).toList();
});

/// Provider للمنتجات المنتهية
final expiredProductsProvider =
    FutureProvider<List<SellerProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getExpiredProducts(sellerId);
  if (result is SuccessState<List<SellerProduct>>) {
    return result.data;
  }
  return [];
});

/// Provider للمنتجات القريبة من الانتهاء
final nearExpiryProductsProvider =
    FutureProvider<List<SellerProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getNearExpiryProducts(sellerId,30);
  if (result is SuccessState<List<SellerProduct>>) {
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

final currentProductProvider = StateProvider<SellerProduct?>((ref) => null);

final expiryDateControllerProvider =
    StateNotifierProvider<ExpiryDateController, ExpiryDatePicker>(
  (ref) => ExpiryDateController(),
);
