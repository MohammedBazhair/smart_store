import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pos_providers.dart';

class QuantityWheelSelector extends ConsumerStatefulWidget {
  const QuantityWheelSelector({super.key});

  @override
  ConsumerState<QuantityWheelSelector> createState() =>
      _QuantityWheelSelectorState();
}

class _QuantityWheelSelectorState extends ConsumerState<QuantityWheelSelector> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: initialIndex);
  }

  int get initialIndex => ref.read(quantitySelectionProvider).quantity - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        ref.watch(quantitySelectionProvider.select((s) => s.quantity));

    return SizedBox(
      height: 200,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          tooltip: 'ارجع إلى القيمة 1',
          child: const Icon(Icons.arrow_upward),
          onPressed: () {
            _controller.animateToItem(
              0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInCubic,
            );
          },
        ),
        body: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: 35,
          useMagnifier: true,
          magnification: 1.2,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            final selectedQuantity = index + 1;
            ref
                .read(quantitySelectionProvider.notifier)
                .update((s) => s.copyWith(quantity: selectedQuantity));
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: 99999999,
            builder: (context, index) {
              final quantity = index + 1;
              return _QuantityItem(
                quantity: quantity,
                selectedValue: selectedValue,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuantityItem extends StatelessWidget {
  const _QuantityItem({
    required this.quantity,
    required this.selectedValue,
  });
  final int quantity;
  final int selectedValue;

  bool get isSelected => selectedValue == quantity;

  @override
  Widget build(BuildContext context) {
    return Baseline(
      baseline: 25,
      baselineType: TextBaseline.alphabetic,
      child: Text(
        '$quantity',
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: isSelected ? 22 : 15,
        ),
      ),
    );
  }
}
