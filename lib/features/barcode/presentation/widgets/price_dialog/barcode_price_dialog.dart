import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../products/domain/entities/store_product.dart';
import '../../../domain/barcode_scan_result.dart';
import 'product_price_content.dart';

Future<void> showProductPriceDialog({
  required BuildContext context,
  required BarcodeScanResult scanResult,
}) async {
  await showDialog(
    context: context,
    builder: (_) => ProviderScope(
      child: ProductPriceDialog(scanResult: scanResult),

    ),
  );
}

class ProductPriceDialog extends StatelessWidget {
  const ProductPriceDialog({super.key, required this.scanResult});
  final BarcodeScanResult scanResult;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: scanResult.isStoreProduct
            ? 
            ProductPriceContent(
                product: scanResult.product as StoreProduct,
              ):const Text('هذا المنتج غير موجود'),
      ),
    );
  }
}
