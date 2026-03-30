import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../settings/domain/entities/currence_code.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';
import '../../../domain/entities/store_product.dart';

class ProductMetaColumn extends ConsumerWidget {
  const ProductMetaColumn(this.product, {super.key});

  final StoreProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:price, :currency) =
        ref.read(settingsControllerProvider.notifier).convert(
              price: product.price,
              from: CurrencyCode.theDefault,
            );

    final priceText = '${price.formatDouble} ${currency.label}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 4,
          children: [
            const Icon(
              Icons.attach_money,
              size: 14,
              color: AppTheme.textSecondary,
            ),
            Text(
              'السعر: $priceText',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        if (product.quantity != null)
          Row(
            spacing: 4,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              Text(
                'الكمية: ${product.quantityText}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        if (product.expiryDate != null)
          Row(
            spacing: 4,
            children: [
              const Icon(
                Icons.calendar_month,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              Text(
                product.expiryDate!.formattedDate,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
