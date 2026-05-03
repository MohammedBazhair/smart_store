import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/cart_item.dart';
import '../controllers/pos_providers.dart';

class DismissibleItem extends ConsumerWidget {
  const DismissibleItem({super.key, required this.item, required this.child});
  final CartItem item;
  final Widget child;

  String get productId => item.product.globalProduct.id!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(posControllerProvider.notifier);

    return Dismissible(
      key: ValueKey(productId),
      direction: DismissDirection.startToEnd,
      onUpdate: (details) {
        if (details.progress > 0.5 && details.progress < 0.6) {
          HapticFeedback.lightImpact();
        }
      },
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Row(
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'حذف',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) {
        notifier.removeCartItem(productId);

        context.showSnakbar(
          'تم حذف المنتج التالي (${item.product.globalProduct.name})',
          type: SnackBarType.success,
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () =>
                notifier.addToCart(item.product, quantity: item.quantity),
          ),
        );

        return Future.value(true);
      },
      child: child,
    );
  }
}
