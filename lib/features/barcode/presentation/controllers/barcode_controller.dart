import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/providers/repositories_provider.dart';
import '../../../../errors/result.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../domain/barcode_scan_result.dart';

/// Controller لإدارة مسح الباركود
class BarcodeController extends Notifier<void> {
  @override
  void build() {}

  /// معالجة الباركود الممسوح
  Future<Result<BarcodeScanResult>> processBarcode(String barcode) async {
    final productRepo = ref.read(productRepositoryProvider);

    // التحقق من وجود المنتج
    final productResult = await productRepo.getProductByBarcode(
      storeId: storeId,
      barcode: barcode,
    );
    StoreProduct? product;

    if (productResult is StoreProduct?) {
      product = productResult;
    }

    if (product?.price == null) return const ErrorState('unfound product');

    final barcodeResult = BarcodeScanResult(
      barcode: barcode,
      product: product,
    );

    return SuccessState(barcodeResult);
  }
}

/// Provider للـ BarcodeController
final barcodeControllerProvider = NotifierProvider<BarcodeController, void>(() {
  return BarcodeController();
});
