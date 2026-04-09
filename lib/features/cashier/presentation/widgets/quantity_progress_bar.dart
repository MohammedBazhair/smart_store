import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quantity_selector.dart';

class QuantityProgressBar extends StatelessWidget {
  const QuantityProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      top: 100,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(30),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const _SliderWidget(),
        ),
      ),
    );
  }
}

class _SliderWidget extends ConsumerWidget {
  const _SliderWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      lastOffsetProvider.select(
        (v) => (v / 100).clamp(0.0, 1.0),
      ),
    );

    return RotatedBox(
      quarterTurns: -1,
      child: Slider(
        value: value,
        onChanged: (_) {},
      ),
    );
  }
}
