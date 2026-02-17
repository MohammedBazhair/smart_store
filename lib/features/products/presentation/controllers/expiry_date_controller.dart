import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expiry_date_picker.dart';

class ExpiryDateController extends StateNotifier<ExpiryDatePicker> {
  ExpiryDateController() : super(ExpiryDatePicker()) {
    _setRanges();
  }

  int _maxDays([int? month]) {
    final now = DateTime.now();
    final selectedMonth = month ?? state.selectedMonth ?? now.month;
    final selectedYear = state.selectedYear ?? now.year;

    return DateTime(
      selectedYear,
      selectedMonth + 1,
      0,
    ).day;
  }

  void _setRanges() {
    final maxDays = _maxDays();
    final now = DateTime.now();
    state = state.copyWith(
      rangeValues: {
        ExpiryDatePickerType.day: List.generate(maxDays, (index) => index + 1),
        ExpiryDatePickerType.month: List.generate(12, (index) => index + 1),
        ExpiryDatePickerType.year:
            List.generate(30, (index) => index + now.year),
      },
    );
  }

  void setDate(DateTime? date) {
    if (date != null) {
      state = state.copyWith(
        selectedDay: date.day,
        selectedMonth: date.month,
        selectedYear: date.year,
      );
    } else {
      state = state.copyWith();
    }
    _setRanges();
  }

  void setDatePicker(ExpiryDatePicker datePicker) {
    state = state.copyWith(
      selectedDay: datePicker.selectedDay,
      selectedMonth: datePicker.selectedMonth,
      selectedYear: datePicker.selectedYear,
    );
  }

  void changeDate(ExpiryDatePickerType typp, int value) {
    switch (typp) {
      case ExpiryDatePickerType.day:
        state = state.copyWith(selectedDay: value);
      case ExpiryDatePickerType.month:
        final ranges = state.rangeValues;
        final maxDays = _maxDays(value);
        final daysItems = List.generate(maxDays, (index) => index + 1);
        final copiedRanges = Map<ExpiryDatePickerType, List<int>>.from(ranges);
        copiedRanges[ExpiryDatePickerType.day] = daysItems;
        final defaultDay = daysItems.contains(state.selectedDay)
            ? state.selectedDay
            : daysItems.first;
        state = state.copyWith(
          selectedMonth: value,
          rangeValues: copiedRanges,
          selectedDay: defaultDay,
        );
      case ExpiryDatePickerType.year:
        state = state.copyWith(selectedYear: value);
    }
  }

  void reset() {
    state = ExpiryDatePicker();
    _setRanges();
  }
}
