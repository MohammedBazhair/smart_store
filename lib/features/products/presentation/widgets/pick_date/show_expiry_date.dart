import 'package:flutter/material.dart';

import 'pick_number.dart';
import 'picker_button.dart';

Future<DateTime?> showExpiryDatePicker(BuildContext context,DateTime ?date) {
  int? selectedDay=date?.day;
  int? selectedMonth=date?.month;
  int? selectedYear=date?.year;

  final now = DateTime.now();

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          int maxDays() {
            if (selectedMonth == null || selectedYear == null) return 31;
            return DateTime(selectedYear!, selectedMonth! + 1, 0).day;
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تاريخ الانتهاء',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    PickerButton(
                      label: selectedDay?.toString() ?? 'يوم',
                      onTap: () async {
                        final day = await pickNumber(
                          context,
                          title: 'اختر اليوم',
                          from: 1,
                          to: maxDays(),
                        );
                        if (day != null) {
                          setState(() => selectedDay = day);
                        }
                      },
                    ),
                    PickerButton(
                      label: selectedMonth?.toString() ?? 'شهر',
                      onTap: () async {
                        final month = await pickNumber(
                          context,
                          title: 'اختر الشهر',
                          from: 1,
                          to: 12,
                        );
                        if (month != null) {
                          setState(() => selectedMonth = month);
                        }
                      },
                    ),
                    PickerButton(
                      label: selectedYear?.toString() ?? 'سنة',
                      onTap: () async {
                        final year = await pickNumber(
                          context,
                          title: 'اختر السنة',
                          from: now.year,
                          to: now.year + 29,
                        );
                        if (year != null) {
                          setState(() => selectedYear = year);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF01B7C1),
                  ),
                  onPressed: (selectedMonth != null && selectedYear != null)
                      ? () {
                          final day = selectedDay ??1;

                          Navigator.pop(
                            context,
                            DateTime(
                              selectedYear!,
                              selectedMonth!,
                              day,
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    'تأكيد',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );
}
