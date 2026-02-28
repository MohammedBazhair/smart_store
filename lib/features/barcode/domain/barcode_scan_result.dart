import '../../products/domain/entities/store_product.dart';

class BarcodeScanResult {
  BarcodeScanResult({
    required this.barcode,
    this.product,
  });
  final String barcode;
  final StoreProduct? product;

  bool get hasPrice => product?.price != null;
}
