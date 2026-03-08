import 'package:flutter/material.dart';

import '../shared/presentation/theme/app_theme.dart';

enum SnackBarType {
  error(
    backgroundColor: AppTheme.errorColor,
    foregroundColor: Colors.white,
    duration: Duration(seconds: 2),
  ),
  success(
    backgroundColor: AppTheme.accentColor,
    foregroundColor: Colors.white,
    duration: Duration(seconds: 1),
  );

  const SnackBarType({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.duration,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Duration duration;
}

enum IsLoading { settings, saveProduct, processBarcode, backup }

enum BackgroundTask { dailyExpiryCheck, addAlertForProduct }

enum SyncOperation {
  insert,
  update,
  delete;

  static SyncOperation fromString(String value) {
    return SyncOperation.values.byName(value);
  }
}
