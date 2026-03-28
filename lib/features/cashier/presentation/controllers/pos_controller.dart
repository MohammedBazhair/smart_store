import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/log.dart';
import '../../../../errors/result.dart';
import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../domain/entities/cart_item.dart';
import 'pos_state.dart';

class PosController extends Notifier<PosState> {
  @override
  PosState build() {
    return const PosState();
  }

  void addToCart(StoreProduct product, {int quantity = 1}) {
    final existingIndex = state.cartItems.indexWhere(
      (item) => item.product.globalProduct.id == product.globalProduct.id,
    );

    if (existingIndex != -1) {
      final existingItem = state.cartItems[existingIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      final updatedCart = [...state.cartItems];
      updatedCart[existingIndex] = updatedItem;
      state = state.copyWith(cartItems: updatedCart);
    } else {
      state = state.copyWith(
        cartItems: [
          ...state.cartItems,
          CartItem(product: product, quantity: quantity),
        ],
      );
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    state = state.copyWith(
      cartItems: state.cartItems.map((item) {
        if (item.product.globalProduct.id == productId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList(),
    );
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      cartItems: state.cartItems
          .where((item) => item.product.globalProduct.id != productId)
          .toList(),
    );
  }

  Future<StoreProduct?> findProductByBarcode(String barcode) async {
    final productsState = ref.read(productControllerProvider);
    // Try to find in loaded products first
    final product = productsState.products[barcode];
    if (product != null) return product;

    // If not found, try to fetch from repo (might be in DB but not in current state)
    // Actually ProductManagementController usually has all store products.
    return null;
  }

  Future<bool> checkout() async {
    if (state.cartItems.isEmpty) return false;

    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(productRepositoryProvider);

      for (final item in state.cartItems) {
        final currentQty = item.product.quantity ?? 0;
        final newQty = currentQty - item.quantity;

        final updatedProduct = item.product.copyWith(
          quantity: newQty < 0 ? 0 : newQty,
          updatedAt: DateTime.now().toUtc(),
        );

        final result = await repo.updateProduct(updatedProduct);
        if (result is ErrorState) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'فشل تحديث كمية ${item.product.globalProduct.name}',
          );
          return false;
        }
      }

      // Success
      await ref.read(audioControllerProvider.notifier).playSuccessResult();

      // We should also refresh the product management state
      await ref.read(productControllerProvider.notifier).loadStoreProducts();

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
