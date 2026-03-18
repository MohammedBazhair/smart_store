import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerState {
  const BarcodeScannerState({
    this.torchState = TorchState.off,
    this.isProcessing = false,
    this.error,
  });

  final TorchState torchState;
  final bool isProcessing;
  final String? error;

  BarcodeScannerState copyWith({
    TorchState? torchState,
    bool? isProcessing,
    String? error,
  }) {
    return BarcodeScannerState(
      torchState: torchState ?? this.torchState,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }
}
