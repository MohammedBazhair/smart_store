import 'package:flutter/material.dart';

import '../../shared/presentation/theme/app_theme.dart';

enum ProductCategory {
  dairy(label: 'ألبان ومنتجاتها'),
  medicine(label: 'أدوية ومستحضرات طبية'),
  drinks(label: 'مشروبات'),
  food(label: 'مواد غذائية وأساسية'),
  sweets(label: 'حلويات ومخبوزات'),
  vegetables(label: 'خضروات وفواكه'),
  meat(label: 'لحوم ودواجن'),
  oils(label: 'زيوت ودهون'),
  spices(label: 'بهارات وتوابل'),
  cleaning(label: 'منظفات ومواد تنظيف'),
  household(label: 'مستلزمات منزلية'),
  office(label: 'معدات وأدوات مكتبية'),
  others(label: 'أخرى');

  const ProductCategory({required this.label});
  final String label;
}

enum Currency {
  YER(label: 'ريال يمني'),
  SAR(label: 'ريال سعودي');

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
    backgroundColor: AppTheme.successColor,
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

enum IsLoading { settings, saveProduct, processBarcode, search, backup }

enum BackgroundTask { dailyExpiryCheck, addAlertForProduct }
