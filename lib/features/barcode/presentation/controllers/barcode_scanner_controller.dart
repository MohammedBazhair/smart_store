import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/log.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../domain/barcode_scan_result.dart';
import 'barcode_scanner_state.dart';

class BarcodeScannerController extends Notifier<BarcodeScannerState> {
  late final MobileScannerController scannerController;

  Timer? _debounce;

  @override
  BarcodeScannerState build() {
    scannerController = MobileScannerController();

    ref.onDispose(() {
      scannerController.stop();
      scannerController.dispose();
      _debounce?.cancel();
    });
    scannerController.start();

    return const BarcodeScannerState();
  }

  Future<void> toggleFlash() async {
    await scannerController.toggleTorch();

    state = state.copyWith(
      torchState:
          state.torchState != TorchState.off ? TorchState.off : TorchState.on,
    );
  }

  /// معالجة الباركود الممسوح
  Future<BarcodeScanResult?> processBarcode(String barcode) async {
    if (state.isProcessing) return null;

    _debounce?.cancel();
    final completer = Completer<BarcodeScanResult?>();

    _debounce = Timer(const Duration(milliseconds: 700), () async {
      state = state.copyWith(isProcessing: true);
      try {
        await HapticFeedback.mediumImpact();

        final product = await ref
            .read(productControllerProvider.notifier)
            .getProductByBarcode(barcode);

        final result = BarcodeScanResult(
          barcode: barcode,
          product: product,
        );

        completer.complete(result);
      } catch (e, st) {
        Logger.debugLog(error: e, stackTrace: st);
        completer.complete(null);
      } finally {
        state = state.copyWith(isProcessing: false);
      }
    });
    return completer.future;
  }

  Future<void> start() => scannerController.start();

  Future<void> stop() => scannerController.stop();
}
