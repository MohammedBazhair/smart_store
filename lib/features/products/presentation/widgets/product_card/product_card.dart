import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../shared/presentation/theme/app_theme.dart';
import '../../../domain/product.dart';
import '../../../domain/product_expiry_status.dart';
import '../../screens/product_details_screen.dart';
import '../products_widgets/product_delete_dialog.dart';
import 'product_meta_column.dart';
import 'product_title.dart';
import 'status_icon.dart';

class AnimatedProductCard extends StatelessWidget {
  const AnimatedProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  Future<bool?> _showDeleteDialog(BuildContext context, Product product) {
    return showDialog<bool?>(
      context: context,
      builder: (_) => ProductDeleteDialog(
        product: product,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        final isDeleted = await _showDeleteDialog(context, product);
        return isDeleted;
      },
      background: const DismissBackground(),
      child: AnimatedProductCardBody(
        product: product,
      ),
    );
  }
}

/// خلفية Swipe للحذف مع Gradient و أيقونة ونص
class DismissBackground extends StatelessWidget {
  const DismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.red.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.delete, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'حذف المنتج',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class AnimatedProductCardBody extends StatelessWidget {
  const AnimatedProductCardBody({
    super.key,
    required this.product,
  });

  final Product product;
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
            context.pushTo(ProductDetailsScreen(productId: product.id!)),
        leading: StatusIcon(status ?? ProductExpiryStatus.valid()),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            Expanded(child: ProductTitle(product.name)),
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
                  product.category.label,
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
            children: [
              ProductMetaColumn(product),
              const Spacer(),
              if (product.expiryDate != null && status?.text != null)
                Container(
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
                    style: TextStyle(
                      color: status.color.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.1, end: 0)
          .then(delay: 100.ms, duration: 150.ms, curve: Curves.easeOutCubic),
    );
  }
}
