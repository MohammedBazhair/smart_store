import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'barcode_scanner_controller.dart';
import 'barcode_scanner_state.dart';


final barcodeControllerProvider =
    NotifierProvider.autoDispose<BarcodeScannerController, BarcodeScannerState>(
  BarcodeScannerController.new,
);
