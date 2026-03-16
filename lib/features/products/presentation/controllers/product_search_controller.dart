import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/log.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/entities/store_product.dart';
import 'product_provider.dart';

class ProductSearchNotifier extends AsyncNotifier<List<StoreProduct>> {
  @override
  Future<List<StoreProduct>> build() async {
      ref.onDispose(() {
      _debounce?.cancel();
    });
    
    return [];
  }

  Timer? _debounce;

  Future<void> search() async {
    Logger.debugLog(message: 'search');
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final query = ref.read(productQueryProvider);
      state = const AsyncLoading();

      state = await AsyncValue.guard(() {
        final productRepo = ref.read(productRepositoryProvider);
        final storeId =
            ref.read(storeControllerProvider).state.selectedStoreId!;

        return productRepo.searchProducts(
          query: query,
          storeId: storeId,
        );
      });
    });
  }
}
