import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/flashlight_controller.dart';

class FlashlightButton extends ConsumerWidget {
  const FlashlightButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final torchState = ref.watch(flashlightProvider);

    return IconButton(
      iconSize: 40,
      highlightColor: Colors.transparent,
      icon: Icon(
        torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
        color: Colors.white,
      ),
      onPressed: () {
        ref.read(flashlightProvider.notifier).toggle();
      },
    );
  }
}
