import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/providers/ui_providers.dart';
import '../../../products/presentation/screens/upsert_product_screen.dart';
import '../controllers/barcode_controller.dart';
import '../controllers/flashlight_controller.dart';
import '../widgets/barcode_camera_view.dart';
import '../widgets/barcode_processing_overlay.dart';
import '../widgets/flashlight_button.dart';
import '../widgets/price_dialog/barcode_price_dialog.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key, this.isPopRequired = false});
  final bool isPopRequired;

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  late final MobileScannerController scannerController;

  @override
  void initState() {
    super.initState();
    scannerController = ref.read(mobileScannerControllerProvider);
  }

  Future<void> _handleBarcode(String barcode) async {
    if (ref.read(isLoadingProvider(IsLoading.processBarcode))) return;

    ref.read(isLoadingProvider(IsLoading.processBarcode).notifier).state = true;

    await scannerController.stop();

    await HapticFeedback.mediumImpact();

    if (!mounted) return;

    if (widget.isPopRequired) {
      Navigator.pop(context, barcode);
      return;
    }

    final barcodeController = ref.read(barcodeControllerProvider.notifier);
    final result = await barcodeController.processBarcode(barcode);

    if (result.isGlobalProduct) {
      context.showSnakbar(
        'المنتج غير مسجل.. قم باضافته أولا',
        type: SnackBarType.error,
      );
      await context.pushTo(
        UpesertProductScreen(
          barcode: barcode,
          product: result.product,
        ),
      );
      ref.read(isLoadingProvider(IsLoading.processBarcode).notifier).state =
          false;
      await scannerController.start();
      return;
    }

    if (result.isStoreProduct) {
      ref.read(isLoadingProvider(IsLoading.processBarcode).notifier).state =
          false;
      await showProductPriceDialog(
        context: context,
        scanResult: result,
      );
      await scannerController.start();
    } else {
      await ref.read(flashlightProvider.notifier).off();
      ref.read(isLoadingProvider(IsLoading.processBarcode).notifier).state =
          false;
      await scannerController.start();
      await context.pushTo(
        UpesertProductScreen(barcode: result.barcode),
      );
    }
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
          BarcodeCameraView(onBarcodeDetected: _handleBarcode),
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
