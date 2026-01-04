import 'package:flutter/material.dart';

import '../constants/enums.dart';

extension ShowSnackbar on BuildContext {
  void showSnakbar(
    String msg, {
    required SnackBarType type,
  }) {
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

  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }
}
