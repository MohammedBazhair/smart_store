import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_provider.dart';

class ProductSearchNotifier extends AsyncNotifier<List<StoreProduct>> {
  ProductRepository get productRepo => ref.read(productRepositoryProvider);

  @override
  Future<List<StoreProduct>> build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    final storeId = ref.read(storeControllerProvider).state.selectedStoreId!;
    return productRepo.searchProducts(
      query: const ProductQuery(),
      storeId: storeId,
    );
  }

  Timer? _debounce;

  Future<void> search(ProductQuery newQuery) async {
    final oldQuery = ref.read(productQueryProvider);

    ref.read(productQueryProvider.notifier).state = newQuery;

    if (oldQuery == newQuery) return;

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      state = const AsyncLoading();

      state = await AsyncValue.guard(() {
        final storeId =
            ref.read(storeControllerProvider).state.selectedStoreId!;

        return productRepo.searchProducts(
          query: newQuery,
          storeId: storeId,
        );
      });
    });
  }
}
