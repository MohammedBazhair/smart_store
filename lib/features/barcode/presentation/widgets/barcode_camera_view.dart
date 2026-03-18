import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../controllers/barcode_provider.dart';
import 'error_scanner_widget.dart';

class BarcodeCameraView extends ConsumerWidget {
  const BarcodeCameraView({
    super.key,
    required this.onBarcodeDetected,
  });

  final ValueChanged<String> onBarcodeDetected;

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(barcodeControllerProvider, (_, state) {
      if (state.error != null) {
        context.showSnakbar(state.error!, type: SnackBarType.error);
      }
    });
    return MobileScanner(
      controller:
          ref.watch(barcodeControllerProvider.notifier).scannerController,
      errorBuilder: (_, error) {
        return ErrorScannerWidget(error: error);
      },
      onDetect: (capture) {
        final barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final barcode = barcodes.first.rawValue;
          if (barcode?.isEmpty ?? true) return;
          onBarcodeDetected(barcode!);
        }
      },
    );
  }
}
