import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/flashlight_controller.dart';
import 'error_scanner_widget.dart';

class BarcodeCameraView extends ConsumerWidget {
  const BarcodeCameraView({
    super.key,
    required this.onBarcodeDetected,
  });

  final ValueChanged<String> onBarcodeDetected;

  @override
  Widget build(BuildContext context,ref) {
    return MobileScanner(
      controller: ref.read(mobileScannerControllerProvider),
      errorBuilder: (_, error, __) {
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
