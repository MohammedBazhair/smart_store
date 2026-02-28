import '../../domain/entities/category.dart';
import '../../domain/entities/store_product.dart';

class ProductManagementState {
  ProductManagementState({this.products = const [], required this.categories});

  final List<StoreProduct> products;
  final List<Category> categories;
}
