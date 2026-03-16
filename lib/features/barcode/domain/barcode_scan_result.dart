import '../../products/domain/entities/product.dart';
import '../../products/domain/entities/store_product.dart';
import '../../products/domain/entities/sub_entities/global_product.dart';

class BarcodeScanResult {
  BarcodeScanResult({
    required this.barcode,
    this.product,
  });
  final String barcode;
  final Product? product;

  bool get isStoreProduct => product is StoreProduct;
  bool get isGlobalProduct => product is GlobalProduct;
  bool get isProductNotFound => product == null;
}
