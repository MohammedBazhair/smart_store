import 'package:flutter/material.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../domain/entities/product_expiry_status.dart';
import '../../../domain/entities/store_product.dart';
import '../../screens/product_details_screen.dart';
import 'product_meta_column.dart';
import 'product_title.dart';
import 'status_icon.dart';

class AnimatedProductCard extends StatelessWidget {
  const AnimatedProductCard({
    super.key,
    required this.product,
  });

  final StoreProduct product;
  @override
  Widget build(BuildContext context) {
    final status = product.expiryDate == null
        ? null
        : ProductExpiryStatus.from(product.expiryDate!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () =>
            context.pushTo(ProductDetailsScreen(productId: product.globalProduct.id!)),
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
          child: Row(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProductMetaColumn(product),
              if (product.expiryDate != null && status?.text != null)
                Flexible(
                  child: Container(
                    height: 30,
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: status?.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status!.text,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: status.color.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      )
        ,
    );
  }
}
