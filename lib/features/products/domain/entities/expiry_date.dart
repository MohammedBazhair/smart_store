enum ExpiryDateFieldType {
  day(label: 'يوم'),
  month(label: 'شهر'),
  year(label: 'سنة');

  const ExpiryDateFieldType({required this.label});
  final String label;
}

class ExpiryDateState {
  ExpiryDateState({
    this.selectedDay,
    this.selectedMonth,
    this.selectedYear,
    this.rangeValues = const {},
  });

  final int? selectedDay;
  final int? selectedMonth;
  final int? selectedYear;

  final Map<ExpiryDateFieldType, List<int>> rangeValues;

  DateTime? get selectedDate {
    if (selectedDay == null || selectedMonth == null || selectedYear == null) {
      return null;
    }
    return DateTime(selectedYear!, selectedMonth!, selectedDay!);
  }

  List<int> getRange(ExpiryDateFieldType type) {
    return rangeValues[type] ?? [];
  }

  int getDefaultValue(ExpiryDateFieldType type) {
    final range = rangeValues[type] ?? [];
    if (range.isEmpty) {
      // Fallback if ranges aren't initialized yet
      if (type == ExpiryDateFieldType.year) return DateTime.now().year;
      return 1;
    }

    final middleIndex = range.length ~/ 2;
    final middleValue = range[middleIndex];
    switch (type) {
      case ExpiryDateFieldType.day:
        return selectedDay ?? middleValue;
      case ExpiryDateFieldType.month:
        return selectedMonth ?? middleValue;
      case ExpiryDateFieldType.year:
        return selectedYear ?? middleValue;
    }
  }

  int getInitialIndex(ExpiryDateFieldType type) {
    final defaultValue = getDefaultValue(type);
    final items = getRange(type);
    final initialIndex = items.indexOf(defaultValue);
    return initialIndex != -1 ? initialIndex : 0;
  }

  ExpiryDateState copyWith({
    int? selectedDay,
    int? selectedMonth,
    int? selectedYear,
    Map<ExpiryDateFieldType, List<int>>? rangeValues,
  }) {
    return ExpiryDateState(
      selectedDay: selectedDay ?? this.selectedDay,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      rangeValues: rangeValues ?? this.rangeValues,
    );
  }
}
