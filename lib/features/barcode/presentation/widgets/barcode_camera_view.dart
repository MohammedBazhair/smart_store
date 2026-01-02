import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeCameraView extends StatelessWidget {
  const BarcodeCameraView({
    super.key,
    required this.controller,
    required this.onBarcodeDetected,

  });

  final MobileScannerController controller;
  final ValueChanged<String> onBarcodeDetected;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
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
