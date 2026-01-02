import '../../products/domain/product.dart';

class BarcodeScanResult {
  BarcodeScanResult({
    required this.barcode,
    this.product,
  });
  final String barcode;
  final Product? product;

  bool get hasPrice => product?.price != null;
}
