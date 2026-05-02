import 'package:equatable/equatable.dart';

import '../../../../core/constants/typedef.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/store_product.dart';

class ProductManagementState extends Equatable {
  const ProductManagementState({
    this.products = const {},
    this.categories = const [],
    this.isLoading = false,
  });

  final ProductsByIdentifier products;
  final List<Category> categories;
  final bool isLoading;

  List<StoreProduct> get productsList => products.values.toList();

  @override
  List<Object?> get props => [
        products,
        categories,
        isLoading,
      ];

  ProductManagementState copyWith({
    ProductsByIdentifier? products,
    List<Category>? categories,
    bool? isLoading,
  }) {
    return ProductManagementState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
