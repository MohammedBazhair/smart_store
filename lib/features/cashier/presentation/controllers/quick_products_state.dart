import '../../../../core/constants/typedef.dart';
import '../../../products/domain/entities/store_product.dart';

enum QuickTabType {
  onlyQuick('المنتجات السريعة'),
  productsWithoutBarcode('بلا باركود');

  const QuickTabType(this.label);
  final String label;
}

class QuickProductsState {
  QuickProductsState({
    required this.quickProducts,
    this.selectedTab = QuickTabType.onlyQuick,
    required this.withoutBarcodeProducts,
  });

  final ProductsByIdentifier quickProducts;
  final List<StoreProduct> withoutBarcodeProducts;
  final QuickTabType selectedTab;

List<StoreProduct> get quickProductsList => quickProducts.values.toList();

List<StoreProduct> get displayedProducts {
  switch (selectedTab) {
    case QuickTabType.onlyQuick:
      return quickProductsList;
    case QuickTabType.productsWithoutBarcode:
      return withoutBarcodeProducts;
  }
}

  QuickProductsState copyWith({
    ProductsByIdentifier? quickProducts,
    QuickTabType? selectedTab,
    List<StoreProduct>? withoutBarcodeProducts,

  }) {
    return QuickProductsState(
      quickProducts: quickProducts ?? this.quickProducts,
      selectedTab: selectedTab ?? this.selectedTab,
      withoutBarcodeProducts: withoutBarcodeProducts ?? this.withoutBarcodeProducts,
    );
  }
}
