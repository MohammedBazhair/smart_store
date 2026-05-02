import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomButton extends ConsumerWidget {
  const CustomButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.buttonStyle,
    this.textStyle,
    this.tooltip,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;
  final String? tooltip;

  @override
  Widget build(BuildContext context, ref) {
    final elevatedButton = ElevatedButton(
      style: buttonStyle,
      onPressed: onPressed,
      child: child,
    );
    return tooltip != null
        ? Tooltip(
            message: tooltip,
            child: elevatedButton,
          )
        : elevatedButton;
  }
}
