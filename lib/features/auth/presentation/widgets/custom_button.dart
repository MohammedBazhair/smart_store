import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../audio/presentation/controller/audio_provider.dart';

class CustomButton extends ConsumerWidget {
  const CustomButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.buttonStyle,
    this.textStyle,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, ref) {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: onPressed != null
          ? () {
              ref.read(audioControllerProvider.notifier).playButtonClick();
              onPressed?.call();
            }
          : null,
      child: child,
    );
  }
}
