import 'package:flutter/material.dart';

import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../products/domain/product.dart';
import '../../../../settings/domain/settings.dart';
import 'animated_price.dart';
import 'converted_price_text.dart';

class ProductPriceContent extends StatelessWidget {
  const ProductPriceContent({
    super.key,
    required this.product,
    required this.settings,
  });

  final Product product;
  final Settings settings;

  bool get _shouldShowConvertedPrice =>
      product.currency != settings.defaultCurrency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'المنتج',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
    
        const SizedBox(height: 12),
    
        // اسم المنتج (ثانوي)
        Text(
          product.name,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
    
        const SizedBox(height: 24),
    
        AnimatedPrice(product),
    
        if (_shouldShowConvertedPrice)
          ConvertedPriceText(
            product: product,
            settings: settings,
          ),
        const SizedBox(height: 30),
      ],
    );
  }
}
