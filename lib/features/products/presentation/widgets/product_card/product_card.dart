import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../domain/product.dart';
import '../../../domain/product_expiry_status.dart';
import '../../screens/product_details_screen.dart';
import '../products_widgets/product_delete_dialog.dart';
import 'expiry_row.dart';
import 'product_meta_row.dart';
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

/// البطاقة نفسها بدون Dismissible
class AnimatedProductCardBody extends StatelessWidget {
  const AnimatedProductCardBody({
    super.key,
    required this.product,
  });

  final Product product;
  @override
  Widget build(BuildContext context) {
    final status = ProductExpiryStatus.from(product.expiryDate);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        minVerticalPadding: 10,
        onTap: () => context.pushTo(ProductDetailsScreen(product: product)),
        leading: StatusIcon(status),
        title: ProductTitle(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            ProductMetaRow(product),
            const SizedBox(height: 6),
            ExpiryRow(product.expiryDate, status),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.1, end: 0)
          .then(delay: 100.ms, duration: 150.ms, curve: Curves.easeOutCubic),
    );
  }
}
