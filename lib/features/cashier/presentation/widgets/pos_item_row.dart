import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../controllers/pos_controller.dart';

class PosItemRow extends ConsumerWidget {
  const PosItemRow({super.key, required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(posControllerProvider.notifier);

    return Dismissible(
      key: ValueKey(
        item.product.globalProduct.id ?? item.product.globalProduct.barcode,
      ),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        notifier.removeFromCart(item.product.globalProduct.id!);
      },
      child: const Text('data'),
    );
  }
}

class QuantitySelector extends ConsumerWidget {
  const QuantitySelector({super.key, required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, ref) {
    final controller = ref.read(posControllerProvider.notifier);
    return Row(
      spacing: 2,
      children: [
        _QuantityButton(
          icon: Icons.remove,
          onPressed: () => controller.updateQuantity(
            item.product.globalProduct.id!,
            item.quantity - 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            '${item.quantity}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onPressed: () => controller.updateQuantity(
            item.product.globalProduct.id!,
            item.quantity + 1,
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
