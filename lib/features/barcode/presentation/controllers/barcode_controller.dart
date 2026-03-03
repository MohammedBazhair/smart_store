import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/controllers/product_provider.dart';
import '../../domain/barcode_scan_result.dart';

/// Controller لإدارة مسح الباركود
class BarcodeController extends Notifier<void> {
  @override
  void build() {}

  /// معالجة الباركود الممسوح
  Future<BarcodeScanResult> processBarcode(String barcode) async {
    final controller = ref.read(productControllerProvider.notifier);
    final product =await controller.getProductByBarcode(barcode);


    final barcodeResult = BarcodeScanResult(
      barcode: barcode,
      product: product,
    );

    return barcodeResult;
  }
}

/// Provider للـ BarcodeController
final barcodeControllerProvider = NotifierProvider<BarcodeController, void>(() {
  return BarcodeController();
});
