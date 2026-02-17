import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/expiry_date_picker.dart';
import '../../domain/entities/seller_product.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/product_query.dart';
import 'expiry_date_controller.dart';

/// Provider للحصول على جميع المنتجات
final productsProvider = FutureProvider<List<SellerProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getAllProducts();
  if (result is SuccessState<List<SellerProduct>>) {
    return result.data;
  }
  return [];
});

final productQueryProvider = StateProvider.autoDispose<ProductQuery>(
  (ref) => ProductQuery(),
);

final searchFilterProductsProvider =
    FutureProvider.autoDispose<List<SellerProduct>>((ref) async {
  final query = ref.watch(productQueryProvider);
  if (!query.hasQuery) return [];

  final repository = ref.watch(productRepositoryProvider);

  final result = query.isSearching
      ? await repository.searchProducts(query.search)
      : await repository.getAllProducts();

  if (result is! SuccessState<List<SellerProduct>>) return [];

  final products = result.data;

  if (!query.hasCategory) return products;

  return products.where((p) => p.category == query.category).toList();
});

/// Provider للمنتجات المنتهية
final expiredProductsProvider =
    FutureProvider<List<SellerProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getExpiredProducts();
  if (result is SuccessState<List<SellerProduct>>) {
    return result.data;
  }
  return [];
});

/// Provider للمنتجات القريبة من الانتهاء
final nearExpiryProductsProvider =
    FutureProvider<List<SellerProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getNearExpiryProducts(30);
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
