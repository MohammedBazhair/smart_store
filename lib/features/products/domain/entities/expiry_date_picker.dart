enum ExpiryDatePickerType {
  day(label: 'يوم'),
  month(label: 'شهر'),
  year(label: 'سنة');

  const ExpiryDatePickerType({required this.label});
  final String label;
}

class ExpiryDatePicker {
  ExpiryDatePicker({
    this.selectedDay,
    this.selectedMonth,
    this.selectedYear,
    this.rangeValues = const {},
  });

  final int? selectedDay;
  final int? selectedMonth;
  final int? selectedYear;

  final Map<ExpiryDatePickerType, List<int>> rangeValues;

  DateTime? get selectedDate {
    if (selectedDay == null || selectedMonth == null || selectedYear == null) {
      return null;
    }
    return DateTime(selectedYear!, selectedMonth!, selectedDay!);
  }

  List<int> getRange(ExpiryDatePickerType type) {
    return rangeValues[type] ?? [];
  }

  int getDefaultValue(ExpiryDatePickerType type) {
    final range = rangeValues[type] ?? [];
    if (range.isEmpty) {
      // Fallback if ranges aren't initialized yet
      if (type == ExpiryDatePickerType.year) return DateTime.now().year;
      return 1;
    }

    final middleIndex = range.length ~/ 2;
    final middleValue = range[middleIndex];
    switch (type) {
      case ExpiryDatePickerType.day:
        return selectedDay ?? middleValue;
      case ExpiryDatePickerType.month:
        return selectedMonth ?? middleValue;
      case ExpiryDatePickerType.year:
        return selectedYear ?? middleValue;
    }
  }

  int getInitialIndex(ExpiryDatePickerType type) {
    final defaultValue = getDefaultValue(type);
    final items = getRange(type);
    final initialIndex = items.indexOf(defaultValue);
    return initialIndex != -1 ? initialIndex : 0;
  }

  ExpiryDatePicker copyWith({
    int? selectedDay,
    int? selectedMonth,
    int? selectedYear,
    Map<ExpiryDatePickerType, List<int>>? rangeValues,
  }) {
    return ExpiryDatePicker(
      selectedDay: selectedDay ?? this.selectedDay,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      rangeValues: rangeValues ?? this.rangeValues,
    );
  }
}
