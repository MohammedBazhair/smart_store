import 'package:mobile_scanner/mobile_scanner.dart';


class BarcodeScannerState {
  const BarcodeScannerState({
    this.torchState = TorchState.off,
    this.isProcessing = false,
  });

  final TorchState torchState;
  final bool isProcessing;

  BarcodeScannerState copyWith({
    TorchState? torchState,
    bool? isProcessing,
  }) {
    return BarcodeScannerState(
      torchState: torchState ?? this.torchState,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
