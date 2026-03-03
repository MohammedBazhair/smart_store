import '../../../../core/constants/typedef.dart';
import '../../domain/entities/category.dart';

class ProductManagementState {
  ProductManagementState({this.products = const {},  this.categories=const[]});

  final ProductsByIdentifier products;
  final List<Category> categories;

  

  ProductManagementState copyWith({
    ProductsByIdentifier? products,
    List<Category>? categories,
  }) {
    return ProductManagementState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
    );
  }
}
