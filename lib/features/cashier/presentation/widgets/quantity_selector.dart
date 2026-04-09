import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/quantity_selection_item.dart';
import '../controllers/pos_controller.dart';
import '../controllers/pos_providers.dart';
import 'quantity_progress_bar.dart';
import 'show_quantity_selector_dialog.dart';

final lastOffsetProvider = StateProvider.autoDispose((ref) => 0.0);
final _entryOverlayProvider = Provider(
  (ref) => OverlayEntry(
    builder: (_) => const QuantityProgressBar(),
  ),
);

class QuantitySelector extends ConsumerWidget {
  const QuantitySelector({super.key, required this.item});
  final CartItem item;

  void onLongMovingPressing(
    LongPressMoveUpdateDetails details,
    WidgetRef ref,
  ) {
    final controller = ref.read(posControllerProvider.notifier);
    final lastOffset = ref.read(lastOffsetProvider);
    final current = details.offsetFromOrigin.dy;
    const step = 10; // 30 PX
    final diff = current - lastOffset;

    if (diff.abs() >= step) {
      final change = diff ~/ step;
      final newQuantity = item.quantity + change;
      controller.updateQuantity(
        item.product.globalProduct.id!,
        newQuantity.clamp(1, 999),
      );
      ref.read(lastOffsetProvider.notifier).state = current;
    }
  }

  void onLongPressStart(WidgetRef ref) {
    ref.read(lastOffsetProvider.notifier).state = 0;

    final overlay = ref.read(_entryOverlayProvider);
    Overlay.of(ref.context).insert(overlay);
  }

  void onLongPressEnd(WidgetRef ref) {
    final overlay = ref.read(_entryOverlayProvider);
    overlay.remove();
  }

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

        controller.updateQuantity(
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
