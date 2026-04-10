import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../settings/domain/entities/currence_code.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';
import '../../controllers/pos_providers.dart';
import '../invoice_sheet.dart';

Future<void> showInvoiceDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const ProviderScope(child: InvoiceSheet());
    },
  );
}

class InvoiceList extends ConsumerWidget {
  const InvoiceList({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final cartItems = ref.read(posControllerProvider).cartItems.values.toList();
    final total = ref.read(posControllerProvider).totalPrice;

    final displayCurrency = ref
        .read(settingsControllerProvider.notifier)
        .convert(
          price: total,
          from: CurrencyCode.theDefault,
        )
        .currency;

    return ListView.builder(
      itemCount: cartItems.length,
      itemExtent: 50,
      itemBuilder: (context, index) {
        final item = cartItems[index];

        final convertedSubtotal = ref
            .read(settingsControllerProvider.notifier)
            .convert(
              price: item.subtotal,
              from: CurrencyCode.theDefault,
            )
            .price;

        return Row(
          children: [
            Expanded(
              child: Text(
                item.product.globalProduct.name,
              ),
            ),
            Text(
              '${item.quantity} x',
            ),
            const SizedBox(width: 8),
            Text(
              '${convertedSubtotal.formatDouble} ${displayCurrency.label}',
            ),
          ],
        );
      },
    );
  }
}
