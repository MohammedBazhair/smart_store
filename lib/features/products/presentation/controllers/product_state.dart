// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import '../../../../core/constants/typedef.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/store_product.dart';

class ProductManagementState extends Equatable {
  const ProductManagementState({
    this.products = const {},
    this.expiredProducts = const [],
    this.nearbyExpiredProducts = const [],
    this.categories = const [],
  });

  final ProductsByIdentifier products;
  final List<StoreProduct> expiredProducts;
  final List<StoreProduct> nearbyExpiredProducts;
  final List<Category> categories;

 
  

  @override
  List<Object?> get props => [products.length, categories.length,expiredProducts.length];

 

  ProductManagementState copyWith({
    ProductsByIdentifier? products,
    List<StoreProduct>? expiredProducts,
    List<StoreProduct>? nearbyExpiredProducts,
    List<Category>? categories,
  }) {
    return ProductManagementState(
      products: products ?? this.products,
      expiredProducts: expiredProducts ?? this.expiredProducts,
      nearbyExpiredProducts: nearbyExpiredProducts ?? this.nearbyExpiredProducts,
      categories: categories ?? this.categories,
    );
  }
}
