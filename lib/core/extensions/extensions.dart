import 'package:flutter/material.dart';

extension ShowSnackbar on BuildContext {
  void showSnakbar(String msg, [Duration duration= const Duration(milliseconds: 1300)]) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(msg), duration: duration),
      
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

