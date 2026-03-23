import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../domain/entities/expiry_date_picker.dart';
import '../../controllers/product_provider.dart';

class PickerButton extends ConsumerStatefulWidget {
  const PickerButton({
    super.key,
    required this.type,
  });

  final ExpiryDatePickerType type;

  @override
  ConsumerState<PickerButton> createState() => _PickerButtonState();
}

class _PickerButtonState extends ConsumerState<PickerButton> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(
      expiryDateControllerProvider
          .select((s) => s.getInitialIndex(widget.type)),
    );
    _controller = FixedExtentScrollController(initialItem: initialIndex);

    // Ensure it's centered even if initialItem had a glitch on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients && _controller.selectedItem != initialIndex) {
        _controller.animateToItem(
          initialIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for range changes (like number of days in month)
    final items = ref.watch(
      expiryDateControllerProvider.select((s) => s.getRange(widget.type)),
    );

    // Watch for selected value changes to update colors
    final selectedValue = ref.watch(
      expiryDateControllerProvider
          .select((s) => s.getDefaultValue(widget.type)),
    );

    // Sync external state changes (like month changing the day)
    ref.listen(
      expiryDateControllerProvider
          .select((s) => s.getInitialIndex(widget.type)),
      (previous, next) {
        if (next != _controller.selectedItem && _controller.hasClients) {
          _controller.animateToItem(
            next,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
    );

    return Column(
      spacing: 12,
      children: [
        Text(
          widget.type.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Expanded(
          child: ListWheelScrollView(
            itemExtent: 30,
            useMagnifier: true,
            magnification: 1.2,
            controller: _controller,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              if (index < items.length) {
                ref
                    .read(expiryDateControllerProvider.notifier)
                    .changeDate(widget.type, items[index]);
              }
            },
            children: items
                .map(
                  (value) => Text(
                    '$value',
                    style: TextStyle(
                      color: value == selectedValue
                          ? Colors.black
                          : AppTheme.textSecondary,
                      fontWeight: value == selectedValue
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
