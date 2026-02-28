import 'package:flutter/material.dart';

import '../../../../../core/constants/enums.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../products/domain/entities/store_product.dart';
import '../../../../settings/domain/settings.dart';

String convertCurrency({
  required num price,
  required Currency from,
  required Currency to,
  required double rate,
}) {
  if (from == Currency.SAR && to == Currency.YER) {
    return (price * rate).toStringAsFixed(2);
  }
  if (from == Currency.YER && to == Currency.SAR) {
    return (price / rate).toStringAsFixed(2);
  }
  return price.toStringAsFixed(2);
}

class ConvertedPriceText extends StatelessWidget {
  const ConvertedPriceText({
    super.key,
    required this.product,
    required this.settings,
  });

  final StoreProduct product;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final converted = convertCurrency(
      price: product.price,
      from: product.currency,
      to: settings.defaultCurrency,
      rate: settings.exchangeRate,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        '≈ $converted ${settings.defaultCurrency.label}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
    );
  }
}
