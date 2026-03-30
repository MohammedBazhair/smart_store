import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../auth/presentation/widgets/wrapper_background.dart';
import '../../../../settings/domain/entities/currence_code.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';
import '../../../domain/entities/product_expiry_status.dart';
import '../../../domain/entities/store_product.dart';
import '../../screens/product_details_screen.dart';
import 'product_meta_column.dart';
import 'product_title.dart';
import 'status_icon.dart';

class AnimatedProductCard extends ConsumerWidget {
  const AnimatedProductCard({
    super.key,
    required this.product,
  });

  final StoreProduct product;
  @override
  Widget build(BuildContext context, ref) {
    final status = product.expiryDate == null
        ? null
        : ProductExpiryStatus.from(product.expiryDate!);
    final (:price, :currency) =
        ref.read(settingsControllerProvider.notifier).convert(
              price: product.price,
              from: CurrencyCode.theDefault,
            );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () => context
            .pushTo(ProductDetailsScreen(productId: product.globalProduct.id!)),
        leading: StatusIcon(status ?? ProductExpiryStatus.valid()),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            Expanded(child: ProductTitle(product.globalProduct.name)),
            Row(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.category,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                Text(
                  product.globalProduct.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IntrinsicHeight(
            child: Row(
              spacing: 15,
              children: [
                ProductMetaColumn(product),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 8,
                    children: [
                      if (product.expiryDate != null && status?.text != null)
                        WrapperBackground(
                          color: status?.color.withOpacity(0.08),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              status!.text,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              style: TextStyle(
                                color: status.color.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      WrapperBackground(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        child: Text.rich(
                          TextSpan(
                            text: price.formatDouble,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: ' ${currency.label}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
