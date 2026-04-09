import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/expiry_date.dart';

class ExpiryDateController extends StateNotifier<ExpiryDateState> {
  ExpiryDateController() : super(ExpiryDateState()) {
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
        ExpiryDateFieldType.day: List.generate(maxDays, (index) => index + 1),
        ExpiryDateFieldType.month: List.generate(12, (index) => index + 1),
        ExpiryDateFieldType.year:
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

  void setDatePicker(ExpiryDateState datePicker) {
    state = state.copyWith(
      selectedDay: datePicker.selectedDay,
      selectedMonth: datePicker.selectedMonth,
      selectedYear: datePicker.selectedYear,
    );
  }

  void changeDate(ExpiryDateFieldType typp, int value) {
    switch (typp) {
      case ExpiryDateFieldType.day:
        state = state.copyWith(selectedDay: value);
      case ExpiryDateFieldType.month:
        final ranges = state.rangeValues;
        final maxDays = _maxDays(value);
        final daysItems = List.generate(maxDays, (index) => index + 1);
        final copiedRanges = Map<ExpiryDateFieldType, List<int>>.from(ranges);
        copiedRanges[ExpiryDateFieldType.day] = daysItems;
        final defaultDay = daysItems.contains(state.selectedDay)
            ? state.selectedDay
            : daysItems.first;
        state = state.copyWith(
          selectedMonth: value,
          rangeValues: copiedRanges,
          selectedDay: defaultDay,
        );
      case ExpiryDateFieldType.year:
        state = state.copyWith(selectedYear: value);
    }
  }

  void reset() {
    state = ExpiryDateState();
    _setRanges();
  }
}
