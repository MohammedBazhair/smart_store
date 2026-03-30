import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../../../../products/domain/entities/store_product.dart';
import '../../../../settings/domain/entities/currence_code.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';

class ConvertedPriceText extends ConsumerWidget {
  const ConvertedPriceText({
    super.key,
    required this.product,
  });

  final StoreProduct product;

  @override
  Widget build(BuildContext context, ref) {
    final asyncSettings = ref.watch(settingsControllerProvider);

    return asyncSettings.when(
      data: (settings) {
        final fromCurrency = CurrencyCode.theDefault;
        final toCurrency = settings.defaultCurrency;
        final converted = ref.read(settingsControllerProvider.notifier).convert(
              price: product.price,
              from: fromCurrency,
              to: toCurrency,
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
      loading: () => const Center(child: ThreeDotsLoading()),
      error: (_, __) => const Center(
        child: Text('حدث خطا ما'),
      ),
    );
  }
}
