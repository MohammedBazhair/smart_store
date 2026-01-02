import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/presentation/widgets/common/conditional_builder.dart';
import '../../../products/presentation/screens/add_product_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../domain/barcode_scan_result.dart';
import '../controllers/barcode_controller.dart';
import '../controllers/flashlight_controller.dart';
import '../widgets/barcode_camera_view.dart';
import '../widgets/barcode_price_dialog.dart';
import '../widgets/barcode_processing_overlay.dart';
import '../widgets/flashlight_button.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key, this.isPopRequired = false});
  final bool isPopRequired;

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  bool _hasPemission = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() async {
    _hasPemission = await PermissionsService.requestCamera();
    setState(() {});
  }


  Future<void> _handleBarcode(String barcode) async {
    final isProcessingState = ref.read(isLoadingProvider);
    if (isProcessingState) return;

    ref.read(isLoadingProvider.notifier).update((_) => true);

    final barcodeController = ref.read(barcodeControllerProvider.notifier);
    final result = await barcodeController.processBarcode(barcode);
    await HapticFeedback.mediumImpact();

    if (!mounted) return;

    if (widget.isPopRequired) {
      Navigator.pop(context, barcode);
      return;
    }

    ref.read(isLoadingProvider.notifier).update((_) => false);

    if (result is ErrorState<BarcodeScanResult>) {
      return context.showSnakbar('المنتج غير مسجل.. قم باضافته أولا');
    }

    final barcodeResult = (result as SuccessState<BarcodeScanResult>).data;

    if (barcodeResult.hasPrice && !isProcessingState) {
      ref.read(isLoadingProvider.notifier).update((_) => true);

      await showBarcodePriceDialog(
        context: context,
        ref: ref,
        result: barcodeResult,
      );
    } else {
      await ref.read(flashlightProvider.notifier).off();
      await context.pushTo(
        AddProductScreen(barcode: barcodeResult.barcode),
      );
    }

    ref.read(isLoadingProvider.notifier).update((_) => false);
  }

  MobileScannerController get scannerController =>
      ref.watch(mobileScannerControllerProvider);

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
          ConditionalBuilder(
            condition: _hasPemission,
            builder: (_) => BarcodeCameraView(
              controller: scannerController,
              onBarcodeDetected: _handleBarcode,
            ),
            fallback: (_) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'الرجاء السماح باستخدام الكاميرا',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      fixedSize: const Size.fromWidth(100),
                    ),
                    onPressed: () async {
                      final hasPermission =  await PermissionsService.requestCamera();
                      if (hasPermission == _hasPemission) return;
                      setState(() {
                        _hasPemission = hasPermission;
                      });
                    },
                    child: const Text('السماح'),
                  ),
                ),
              ],
            ),
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
