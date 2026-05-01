// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  @override
  String toString() => 'BarcodeScanResult(barcode: $barcode, product: $product)';
}
