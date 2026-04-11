import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/enums.dart';

extension ShowSnackbar on BuildContext {
  void showSnakbar(
    String msg, {
    required SnackBarType type,
    SnackBarAction? action,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            color: type.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        duration: type.duration,
        action: action,
        backgroundColor: type.backgroundColor,
      ),
    );
  }
}

extension RoutesNavigators on BuildContext {
  Future<T?> pushTo<T extends Object?>(Widget screen) {
    return Navigator.push(
      this,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<T?> pushReplacementTo<T extends Object?, TO extends Object?>(
    Widget screen,
  ) {
    return Navigator.pushReplacement(
      this,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<T?> pushAndRemoveUntilTo<T extends Object?>(Widget screen) {
    return Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }
}

extension Number on num {
  String get formatDouble =>
      this == truncateToDouble() ? toStringAsFixed(0) : toStringAsFixed(2);
}

extension FilesSizes on num {
  double get bytesToMb => this / (1024 * 1024);
}

extension DateFormating on DateTime {
  String get formattedDate {
    return DateFormat('yyyy/MM/dd').format(this);
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(this);
  }

  DateTime get toDateOnly => DateTime(year, month, day);
}

extension BoolToInt on bool {
  int get toInt => this ? 1 : 0;
}
