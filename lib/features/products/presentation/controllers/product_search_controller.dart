import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/log.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/search_product_repository.dart';
import 'product_provider.dart';

class ProductSearchController extends AsyncNotifier<List<StoreProduct>> {
  SearchProductRepository get _searchProductRepo =>
      ref.read(searchProductRepositoryProvider);

  final searchController = SearchController();

  @override
  Future<List<StoreProduct>> build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _suggestionsDebounce?.cancel();
      searchController.dispose();
    });

    return initialState();
  }

  Timer? _debounce;
  Timer? _suggestionsDebounce;

  Future<void> search(ProductQuery newQuery) async {
    final oldQuery = ref.read(productQueryProvider);

    ref.read(productQueryProvider.notifier).state = newQuery;

    if (oldQuery == newQuery) return;

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      state = const AsyncLoading();
      final storeId = ref.read(storeControllerProvider).state.selectedStoreId;

      if (storeId == null) return;

      state = await AsyncValue.guard(() {
        return _searchProductRepo.searchStoreProducts(
          query: newQuery,
          storeId: storeId,
        );
      });
    });
  }

  Future<List<String>> searchProductsNamesSuggestions(String query) async {
    final storeId = ref.read(storeControllerProvider).state.selectedStoreId;

    if (storeId == null || query.trim().isEmpty) return [];

    _suggestionsDebounce?.cancel();

    final completer = Completer<List<String>>();

    _suggestionsDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final result = await _searchProductRepo.searchProductsNamesSuggestions(
          query: query.trim(),
          storeId: storeId,
        );

        completer.complete(result);
      } catch (e, st) {
        Logger.debugLog(error: e, stackTrace: st);
        completer.complete([]);
      }
    });

    return completer.future;
  }

  Future<void> reset() async {
    try {
      if (!ref.mounted) return;

      state = const AsyncValue.loading();

      if (!ref.mounted) return;
      final _state = await initialState();
      state = AsyncData(_state);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  Future<void> clearSearch() async {
    searchController.text = '';
    ref
        .read(productQueryProvider.notifier)
        .update((c) => c.copyWith(search: ''));
    await reset();
  }

  Future<void> clearCategory() async {
    ref
        .read(productQueryProvider.notifier)
        .update((c) => c.copyWith(clearCategory: true));

    await reset();
  }

  Future<List<StoreProduct>> initialState() async {
    final storeId = ref.read(storeControllerProvider).state.selectedStoreId;

    if (storeId == null) return <StoreProduct>[];
    return _searchProductRepo.searchStoreProducts(
      query: const ProductQuery(),
      storeId: storeId,
    );
  }
}
