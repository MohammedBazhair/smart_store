import 'package:flutter/material.dart';

import '../shared/presentation/theme/app_theme.dart';



enum Currency {
  YER(label: 'يمني'),
  SAR(label: 'سعودي');

  const Currency({required this.label});
  final String label;
}

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
