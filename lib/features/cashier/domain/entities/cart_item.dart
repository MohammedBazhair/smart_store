import '../../../products/domain/entities/store_product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
  });
  final StoreProduct product;
  final int quantity;

  double get subtotal => (product.price * quantity).toDouble();

  CartItem copyWith({
    StoreProduct? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() =>
      'CartItem(product: ${product.globalProduct.name}, quantity: $quantity)';
}
