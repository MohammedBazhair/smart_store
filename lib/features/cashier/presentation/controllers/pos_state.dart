import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

class PosState extends Equatable {
  const PosState({
    this.cartItems = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  final List<CartItem> cartItems;
  final bool isLoading;
  final String? errorMessage;

  double get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  PosState copyWith({
    List<CartItem>? cartItems,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PosState(
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [cartItems, isLoading, errorMessage];
}
