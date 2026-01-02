import 'package:flutter/material.dart';

class ConditionalBuilder extends StatelessWidget {
  const ConditionalBuilder({
    super.key,
    required this.condition,
    required this.builder,
    this.fallback,
  });
  final bool condition;
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context)? fallback;

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return builder(context);
    } else {
      return fallback?.call(context) ?? const SizedBox.shrink();
    }
  }
}
