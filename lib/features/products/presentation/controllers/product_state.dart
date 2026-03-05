import '../../../../core/constants/typedef.dart';
import '../../../settings/domain/entities/exchange_rate.dart';
import '../../domain/entities/category.dart';

class ProductManagementState {
  ProductManagementState({
    this.products = const {},
    this.categories = const [],
    this.exchangeRates = const [],
    this.isInitilizating = false,
  });

  final ProductsByIdentifier products;
  final List<Category> categories;
  final List<ExchangeRate> exchangeRates;
  final bool isInitilizating;

  ProductManagementState copyWith({
    ProductsByIdentifier? products,
    List<Category>? categories,
    List<ExchangeRate>? exchangeRates,
    bool? isInitilizating,
  }) {
    return ProductManagementState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      isInitilizating: isInitilizating ?? this.isInitilizating,
    );
  }
}
