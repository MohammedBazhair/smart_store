import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/log.dart';
import '../../../../errors/result.dart';
import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../../settings/domain/entities/exchange_rate.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../../domain/entities/cart_item.dart';
import 'pos_state.dart';

class PosController extends Notifier<PosState> {
  @override
  PosState build() {
    return const PosState();
  }

  ExchangeRate get baseExchangeRate =>
      ref.read(settingsControllerProvider).value?.defaultExchangeRate ??
      ExchangeRate.defaultRate();

  void addToCart(StoreProduct product, {int quantity = 1}) {
    final copiedCart = {...state.cartItems};
    copiedCart.update(
      product.id!,
      (item) => item.copyWith(quantity: item.quantity + quantity),
      ifAbsent: () =>
          CartItem(product: product, quantity: quantity, price: product.price),
    );

    state = state.copyWith(cartItems: copiedCart);
  }

  void updateQuantity(String productId, int quantity) {
                      ref.read(audioControllerProvider.notifier).playClick();
    
    final copiedCart = {...state.cartItems};
    copiedCart.update(
      productId,
      (item) => item.copyWith(quantity: quantity),
    );

    state = state.copyWith(cartItems: copiedCart);
  }

  void removeFromCart(String productId) {
    final copiedCart = {...state.cartItems};
    copiedCart.remove(productId);

    state = state.copyWith(cartItems: copiedCart);
  }

  Future<StoreProduct?> findProductByBarcode(String barcode) async {
    final productState = ref.read(productControllerProvider);
    return productState.products[barcode];
  }

  Future<bool> checkout() async {
    if (state.cartItems.isEmpty) return false;

    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(productRepositoryProvider);

      for (final item in state.cartItems.values) {
        final currentQty = item.product.quantity ?? 0;
        final newQty = currentQty - item.quantity;

        final updatedProduct = item.product.copyWith(
          quantity: newQty < 0 ? 0 : newQty,
          updatedAt: DateTime.now().toUtc(),
        );

        final result = await repo.updateProduct(updatedProduct);
        if (result is ErrorState<void>) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'فشل تحديث كمية ${item.product.globalProduct.name}',
          );
          return false;
        }
      }

      await ref.read(audioControllerProvider.notifier).playSuccessResult();

      await ref.read(productControllerProvider.notifier).loadStoreProducts();
      ref.invalidate(productByIdProvider);

      return true;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ غير متوقع أثناء عملية الشراء',
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearCart() {
    state = const PosState();
  }
}

final posControllerProvider = NotifierProvider<PosController, PosState>(() {
  return PosController();
});
