import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../../../products/domain/entities/store_product.dart';
import '../../../../settings/domain/entities/currence_code.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';
import 'animated_price.dart';
import 'converted_price_text.dart';

class ProductPriceContent extends ConsumerWidget {
  const ProductPriceContent({
    super.key,
    required this.product,
  });

  final StoreProduct product;

  @override
  Widget build(BuildContext context, ref) {
    final asyncSettings = ref.watch(settingsControllerProvider);

    return asyncSettings.when(
      data: (settings) {
        final defaultCurrency = settings.defaultCurrency;
        final _shouldShowConvertedPrice = defaultCurrency != CurrencyCode.theDefault;

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
              product.globalProduct.name,
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
              ),
            const SizedBox(height: 30),
          ],
        );
      },
      loading: () => const Center(child: LoadingWidget()),
      error: (_, __) => const Center(child: Text('حدث خطا ما')),
    );
  }
}
