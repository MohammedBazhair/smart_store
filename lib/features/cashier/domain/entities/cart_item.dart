import '../../../products/domain/entities/store_product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
    required this.price,
  });
  final StoreProduct product;
  final int quantity;
  final num price; // Always in base currency (YER)
  double get subtotal => (price * quantity).toDouble();

  CartItem copyWith({
    StoreProduct? product,
    int? quantity,
    num? price,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  String toString() =>
      'CartItem(product: ${product.globalProduct.name}, quantity: $quantity)';
}
