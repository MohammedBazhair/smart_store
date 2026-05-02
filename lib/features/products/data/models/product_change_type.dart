import '../../domain/entities/store_product.dart';

class ProductChangeType {
  const ProductChangeType({
    required this.globalChanged,
    required this.storeChanged,
  });

  factory ProductChangeType.detectChanges({
    required StoreProduct oldP,
    required StoreProduct newP,
  }) {
    final globalChanged = oldP.globalProduct.name != newP.globalProduct.name ||
        oldP.globalProduct.barcode != newP.globalProduct.barcode ||
        oldP.globalProduct.category.id != newP.globalProduct.category.id;

    final storeChanged = oldP.price != newP.price ||
        oldP.quantity != newP.quantity ||
        oldP.expiryDate != newP.expiryDate ||
        oldP.notes != newP.notes;

    return ProductChangeType(
      globalChanged: globalChanged,
      storeChanged: storeChanged,
    );
  }
  final bool globalChanged;
  final bool storeChanged;
}
