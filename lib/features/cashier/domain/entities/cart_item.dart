import '../../../products/domain/entities/store_product.dart';
import '../../../settings/domain/entities/exchange_rate.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
    required this.baseExchangeRate,
  });
  final StoreProduct product;
  final int quantity;
  final ExchangeRate baseExchangeRate;

  double get price => (product.price * baseExchangeRate.rateToBase).toDouble();
  double get subtotal => (product.price * quantity).toDouble();

  CartItem copyWith({
    StoreProduct? product,
    int? quantity,
    ExchangeRate? baseExchangeRate,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      baseExchangeRate: baseExchangeRate ?? this.baseExchangeRate,
    );
  }

  @override
  String toString() =>
      'CartItem(product: ${product.globalProduct.name}, quantity: $quantity)';
}
