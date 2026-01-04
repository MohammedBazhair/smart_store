import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

final mobileScannerControllerProvider = Provider((ref) {
  final controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  
  ref.onDispose(() {
    controller.stop();
    controller.dispose();
    print('---------------------------');
    print('disposed');
    print('---------------------------');
  });

  return controller;
});

final flashlightProvider =
    StateNotifierProvider<FlashlightNotifier, TorchState>(
  (ref) {
    final controller = ref.read(mobileScannerControllerProvider);
    return FlashlightNotifier(controller);
  },
);

class FlashlightNotifier extends StateNotifier<TorchState> {
  FlashlightNotifier(this._controller) : super(TorchState.off) {
    _controller.addListener(_listener);
  }

  final MobileScannerController _controller;

  void _listener() {
    state = _controller.value.torchState;
  }

  Future<void> toggle() => _controller.toggleTorch();

  Future<void> off() async {
    if (state == TorchState.on) await _controller.toggleTorch();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.removeListener(_listener);
    super.dispose();
  }
}
