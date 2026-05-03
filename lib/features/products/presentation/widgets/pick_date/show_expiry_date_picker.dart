import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../../core/shared/presentation/widgets/common/bottom_sheet_handle.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../auth/presentation/widgets/custom_button.dart';
import '../../../domain/entities/expiry_date.dart';
import '../../controllers/product_provider.dart';
import 'expiry_date_wheel_picker.dart';

Future<DateTime?> showExpiryDatePicker(BuildContext context, WidgetRef ref) {
  final now = DateTime.now();

  void setDate() {
    final state = ref.read(expiryDateControllerProvider);
    final day = state.selectedDay ?? 1;
    final month = state.selectedMonth ?? 1;
    final year = state.selectedYear ?? now.year;
    final datePicker = ExpiryDateState(
      selectedDay: day,
      selectedMonth: month,
      selectedYear: year,
    );
    ref
        .read(
          expiryDateControllerProvider.notifier,
        )
        .setDatePicker(datePicker);
  }

  return showModalBottomSheet<DateTime?>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => ExpiryDatePickerDialog(setDate: setDate),
  );
}

class ExpiryDatePickerDialog extends StatelessWidget {
  const ExpiryDatePickerDialog({super.key, required this.setDate});

  final VoidCallback setDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          const Text(
            'تاريخ الانتهاء',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (__, ref, _) {
              final date = ref.watch(expiryDateControllerProvider).selectedDate;
              return date != null
                  ? Text(
                      DateTimeUtils.timeUntilExpiry(date).toString(),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: ExpiryDateWheelPicker(
                    type: ExpiryDateFieldType.day,
                  ),
                ),
                Expanded(
                  child: ExpiryDateWheelPicker(
                    type: ExpiryDateFieldType.month,
                  ),
                ),
                Expanded(
                  child: ExpiryDateWheelPicker(
                    type: ExpiryDateFieldType.year,
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
              setDate();
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
    );
  }
}
