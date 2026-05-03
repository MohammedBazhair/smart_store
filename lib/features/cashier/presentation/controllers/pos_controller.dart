import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/log.dart';
import '../../../audio/presentation/controller/audio_provider.dart';

import '../../../products/data/models/product_change_type.dart';
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

  ExchangeRate get defaultExchangeRate =>
      ref.read(settingsControllerProvider).value?.defaultExchangeRate ??
      ExchangeRate.defaultRate();

  void addToCart(StoreProduct product, {int quantity = 1}) {
    final updatedCartItems = {...state.cartItems};
    updatedCartItems.update(
      product.id!,
      (item) => item.copyWith(quantity: item.quantity + quantity),
      ifAbsent: () =>
          CartItem(product: product, quantity: quantity, price: product.price),
    );

    state = state.copyWith(cartItems: updatedCartItems);
  }

  void updateCartItemQuantity(String productId, int quantity) {
    ref.read(audioControllerProvider.notifier).playClick();

    final updatedCartItems = {...state.cartItems};
    updatedCartItems.update(
      productId,
      (item) => item.copyWith(quantity: quantity),
    );

    state = state.copyWith(cartItems: updatedCartItems);
  }

  void removeCartItem(String productId) {
    final updatedCartItems = {...state.cartItems};
    updatedCartItems.remove(productId);

    state = state.copyWith(cartItems: updatedCartItems);
  }

  Future<bool> processCheckout() async {
    if (state.cartItems.isEmpty) return false;

    final cartSnapshot = {...state.cartItems};

    state = state.copyWith(isLoading: true);

    try {
      final productRepo = ref.read(productRepositoryProvider);

      const changeType = ProductChangeType(
        globalChanged: false,
        storeChanged: true,
      );
      await Future.wait(
        cartSnapshot.values.map((item) {
          final currentQty = item.product.quantity ?? 0;
          final updatedQuantity =
              (currentQty - item.quantity).clamp(0, currentQty);


          final updatedProduct = item.product.copyWith(
            quantity: updatedQuantity,
            updatedAt: DateTime.now().toUtc(),

          );

          return productRepo.updateProduct(
            updatedProduct,
            changeType,
          );
        }),
      );


      await ref.read(audioControllerProvider.notifier).playSuccessResult();

       // ignore: unawaited_futures
       ref.read(productControllerProvider.notifier).loadStoreProducts();

      return true;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);

      state = state.copyWith(
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
