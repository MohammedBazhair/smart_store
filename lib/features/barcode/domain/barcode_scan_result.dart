import '../../products/domain/entities/seller_product.dart';

class BarcodeScanResult {
  BarcodeScanResult({
    required this.barcode,
    this.product,
  });
  final String barcode;
  final SellerProduct? product;

  bool get hasPrice => product?.price != null;
}
