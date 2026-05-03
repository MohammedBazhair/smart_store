import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../products/data/models/store_product_key.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/repositories/quick_products_repository.dart';
import 'pos_providers.dart';
import 'quick_products_state.dart';

class QuickProductsController extends AsyncNotifier<QuickProductsState> {
  QuickProductsRepository get _quickRepo => ref.read(quickProductsRepository);

  String? get _storeId => ref.watch(
        storeControllerProvider.select(
          (s) => s.state.selectedStoreId,
        ),
      );

  @override
  Future<QuickProductsState> build() async {
    final quickProducts = await _getQuickProducts();
    final withoutBarcodeProducts = await _getWithoutBarcodeProducts();

    return QuickProductsState(
      quickProducts: quickProducts,
      withoutBarcodeProducts: withoutBarcodeProducts,
    );
  }

  Future<ProductsByIdentifier> _getQuickProducts() async {
    if (_storeId == null) return {};

    final ids = await _quickRepo.getQuickProductsIds(_storeId!);
    Logger.debugLog(message: '$ids');
    final allProducts = ref.watch(productControllerProvider).products;

    final quickProducts = <String, StoreProduct>{};

    for (final id in ids) {
      final product = allProducts[id];

      if (product != null) {
        quickProducts[id] = product;
      } else {
        final productKey = StoreProductKey(storeId: _storeId!, productId: id);
        // ignore: unawaited_futures
        _quickRepo.removeQuickProduct(productKey);
      }
    }

    return quickProducts;
  }

  Future<List<StoreProduct>> _getWithoutBarcodeProducts() async {
    final repo = ref.read(productRepositoryProvider);
    if (_storeId == null) return [];
    return repo.getWithoutBarcodeProducts(_storeId!);
  }

  Future<void> toggleProduct(StoreProduct product) async {
    if (_storeId == null || product.id == null) return;
    final productKey =
        StoreProductKey(storeId: _storeId!, productId: product.id!);

    final currentState = state.asData?.value;
    if (currentState == null) return;

    final copiedProducts = {...currentState.quickProducts};

    final exists = copiedProducts.containsKey(productKey.productId);

    exists
        ? copiedProducts.remove(productKey.productId)
        : copiedProducts[productKey.productId] = product;

    state = AsyncData(currentState.copyWith(quickProducts: copiedProducts));

    try {
      exists
          ? await _quickRepo.removeQuickProduct(productKey)
          : await _quickRepo.addQuickProduct(productKey);
    } catch (e, st) {
      state = AsyncData(currentState);
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  Future<void> changeTab(QuickTabType type) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    if (currentState.selectedTab != type) {
      state = AsyncData(currentState.copyWith(selectedTab: type));
    }
  }
}
