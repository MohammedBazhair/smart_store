import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../../../products/domain/entities/store_product.dart';
import '../../../../settings/domain/entities/currence_code.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';

String convertCurrency({
  required num price,
  required CurrencyCode from,
  required CurrencyCode to,
  required int rate,
}) {
  if (from == CurrencyCode.SAR && to == CurrencyCode.YER) {
    return (price * rate).toStringAsFixed(2);
  }
  if (from == CurrencyCode.YER && to == CurrencyCode.SAR) {
    return (price / rate).toStringAsFixed(2);
  }
  return price.toStringAsFixed(2);
}

class ConvertedPriceText extends ConsumerWidget {
  const ConvertedPriceText({
    super.key,
    required this.product,
  });

  final StoreProduct product;

  @override
  Widget build(BuildContext context, ref) {
    final asyncSettings = ref.watch(settingsControllerProvider);

   return  asyncSettings.when(
      data: (settings) {
        final converted = convertCurrency(
          price: product.price,
          from: product.currency,
          to: settings.defaultCurrency,
          rate: settings.defaultExchangeRate.rateToBase,
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
      },
      loading: () => const Center(child: LoadingWidget()),
      error: (_, __) => const Center(
        child: Text('حدث خطا ما'),
      ),
    );
  }
}
