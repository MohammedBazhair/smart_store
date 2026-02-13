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
    return AnimatedCrossFade(
      firstChild: builder(context),
      secondChild: fallback?.call(context) ?? const SizedBox.shrink(),
      crossFadeState:
          condition ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 600),
      firstCurve: Curves.easeInOutExpo,
      secondCurve: Curves.easeInQuad,
    );
  }
}
