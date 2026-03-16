import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../products/presentation/screens/upsert_product_screen.dart';
import '../controllers/barcode_provider.dart';
import '../widgets/barcode_camera_view.dart';
import '../widgets/barcode_processing_overlay.dart';
import '../widgets/flashlight_button.dart';
import '../widgets/price_dialog/barcode_price_dialog.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key, this.isPopRequired = false});
  final bool isPopRequired;

  Future<void> _handleBarcode(
    String barcode,
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (isPopRequired) {
      Navigator.pop(context, barcode);
      return;
    }
    final controller = ref.read(barcodeControllerProvider.notifier);

    final result = await controller.processBarcode(barcode);

    if (result == null) return;

    if (result.isStoreProduct) {
      await controller.stop();
      await showProductPriceDialog(context: context, scanResult: result);
      await controller.start();
      return;
    }

    context.showSnakbar(
      'المنتج غير موجود قم بتسجيله',
      type: SnackBarType.error,
    );

    if (!context.mounted) return;
    await context.pushTo(
      UpesertProductScreen(
        barcode: barcode,
        product: result.product,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'امسح الباركود',
        ),
      ),
      body: Stack(
        children: [
          Consumer(
            builder: (_, ref, __) {
              return BarcodeCameraView(
                onBarcodeDetected: (barcode) =>
                    _handleBarcode(barcode, context, ref),
              );
            },
          ),
          const Align(child: BarcodeProcessingOverlay()),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: FlashlightButton(),
          ),
        ],
      ),
    );
  }
}
