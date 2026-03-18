import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../auth/presentation/widgets/custom_button.dart';
import '../../../domain/entities/expiry_date_picker.dart';
import '../../controllers/product_provider.dart';
import 'picker_button.dart';

Future<DateTime?> showExpiryDatePicker(BuildContext context, WidgetRef ref) {
  final now = DateTime.now();

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return ProviderScope(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تاريخ الانتهاء',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: PickerButton(
                        type: ExpiryDatePickerType.day,
                      ),
                    ),
                    Expanded(
                      child: PickerButton(
                        type: ExpiryDatePickerType.month,
                      ),
                    ),
                    Expanded(
                      child: PickerButton(
                        type: ExpiryDatePickerType.year,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                buttonStyle: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFF01B7C1),
                ),
                onPressed: () {
                  final state = ref.read(expiryDateControllerProvider);
                  final day = state.selectedDay ?? 1;
                  final month = state.selectedMonth ?? 1;
                  final year = state.selectedYear ?? now.year;
                  final datePicker = ExpiryDatePicker(
                    selectedDay: day,
                    selectedMonth: month,
                    selectedYear: year,
                  );
                  ref
                      .read(
                        expiryDateControllerProvider.notifier,
                      )
                      .setDatePicker(datePicker);
                  context.pop();
                },
                child: const Text(
                  'تأكيد',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}
