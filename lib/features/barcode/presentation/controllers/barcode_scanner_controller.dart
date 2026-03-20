import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/shared/domain/entities/permission.dart';
import '../../../../core/shared/domain/services/permission_service.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../domain/barcode_scan_result.dart';
import 'barcode_scanner_state.dart';

class BarcodeScannerController extends Notifier<BarcodeScannerState> {
  late final MobileScannerController scannerController;
  late final PermissionService _permissionService;

  Timer? _debounce;

  @override
  BarcodeScannerState build() {
    _permissionService = ref.read(permissionServiceProvider);
    scannerController = MobileScannerController(autoStart: false);

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
  Future<BarcodeScanResult?> processBarcode(
    String barcode, [
    bool isPop = false,
  ]) async {
    if (!_permissionService.can(PermissionTask.scanBarcodeViewPrice)) {
      state = state.copyWith(
        error: 'لا توجد لديك صلاحية مسح المنتجات عبر الباركود',
      );
      return null;
    }

    if (state.isProcessing) return null;

    state = state.copyWith(isProcessing: true);

    _debounce?.cancel();
    final completer = Completer<BarcodeScanResult?>();

    _debounce = Timer(const Duration(milliseconds: 700), () async {
      try {
        if (isPop) {
          await ref.read(audioControllerProvider.notifier).playScannerBeep();

          completer.complete(null);
          return;
        }

        final product = await ref
            .read(productControllerProvider.notifier)
            .getProductByBarcode(barcode);

        await ref.read(audioControllerProvider.notifier).playScannerBeep();

        final result = BarcodeScanResult(
          barcode: barcode,
          product: product,
        );

        completer.complete(result);
      } catch (e, st) {
        Logger.debugLog(error: e, stackTrace: st);
        state =
            state.copyWith(error: 'حصلت مشكلة أثناء مسح المنتج لعرض تفاصيله');
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
