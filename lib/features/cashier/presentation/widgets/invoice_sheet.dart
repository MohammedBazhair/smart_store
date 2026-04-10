import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../settings/domain/entities/currence_code.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../controllers/pos_providers.dart';
import 'dialogs/show_invoice_dialog.dart';

class InvoiceSheet extends ConsumerWidget {
  const InvoiceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.read(posControllerProvider).totalPrice;

    final result = ref.read(settingsControllerProvider.notifier).convert(
          price: total,
          from: CurrencyCode.theDefault,
        );

    final convertedTotal = result.price;
    final currency = result.currency;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ✅ Header
            const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 8),
                Text(
                  'تمت العملية بنجاح',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            /// ✅ القائمة
            const Expanded(child: InvoiceList()),

            const Divider(),

            /// ✅ الإجمالي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${convertedTotal.formatDouble} ${currency.label}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ✅ الأزرار
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}
