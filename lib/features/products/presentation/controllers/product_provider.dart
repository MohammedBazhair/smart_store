import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../domain/product.dart';
import '../../domain/product_details.dart';

/// Provider للحصول على جميع المنتجات
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getAllProducts();
  if (result is SuccessState<List<Product>>) {
    return result.data;
  }
  return [];
});

/// Provider للبحث عن المنتجات
final searchProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) {
    final repository = ref.watch(productRepositoryProvider);
    final result = await repository.getAllProducts();
    if (result is SuccessState<List<Product>>) {
      return result.data;
    }
    return [];
  }
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.searchProducts(query);
  if (result is SuccessState<List<Product>>) {
    return result.data;
  }
  return [];
});

/// Provider للمنتجات المنتهية
final expiredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getExpiredProducts();
  if (result is SuccessState<List<Product>>) {
    return result.data;
  }
  return [];
});

/// Provider للمنتجات القريبة من الانتهاء
final nearExpiryProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getNearExpiryProducts(30);
  if (result is SuccessState<List<Product>>) {
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

final currentProductProvider = StateProvider<Product?>((ref) => null);
