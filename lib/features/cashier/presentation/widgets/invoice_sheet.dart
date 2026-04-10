import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../printinig_share/services/print_service.dart';
import '../../../printinig_share/services/share_service.dart';
import '../../../settings/domain/entities/currence_code.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../controllers/pos_providers.dart';
import 'pos_checkout_footer.dart';

class InvoiceSheet extends StatelessWidget {
  const InvoiceSheet({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفاتورة'),
        backgroundColor: Colors.grey.shade800,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المنتج',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'الإجمالي',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          const Expanded(child: InvoiceList()),
          PosCheckoutFooterWrapper(
            child: Column(
              children: [
                const CartTotalView(),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final invoice = ref.read(invoiceProvider);
                    return Row(
                      children: [
                        Expanded(
                          child: InvoiceAction(
                            onPressed: () => PrintService().printInvoice(invoice),
                            icon: Icons.print,
                            label: 'طباعة',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InvoiceAction(
                            onPressed: () => ShareService().shareInvoice(invoice),
                            icon: Icons.share_rounded,
                            label: 'مشاركة',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceAction extends StatelessWidget {
  const InvoiceAction({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppTheme.secondaryColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
      ),
      label: Text(label),
    );
  }
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

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = cartItems[index];

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
              item.price.formatDouble,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayCurrency.label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        );
      },
    );
  }
}
