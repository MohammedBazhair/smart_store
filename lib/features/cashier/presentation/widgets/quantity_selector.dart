import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/quantity_selection_item.dart';
import '../controllers/pos_providers.dart';
import 'dialogs/show_quantity_selector_dialog.dart';

class QuantitySelector extends ConsumerWidget {
  const QuantitySelector({super.key, required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, ref) {
    final controller = ref.read(posControllerProvider.notifier);
    return InkWell(
      onTap: () async {
        final selectionItem = QuantitySelectionItem(
          productName: item.product.globalProduct.name,
          quantity: item.quantity,
        );
        ref.read(quantitySelectionProvider.notifier).state = selectionItem;

        await showQuantitySelector(context);
        final newQuantity = ref.read(quantitySelectionProvider).quantity;
        if (newQuantity == item.quantity) return;

        controller.updateCartItemQuantity(
          item.product.globalProduct.id!,
          newQuantity,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${item.quantity}',
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
