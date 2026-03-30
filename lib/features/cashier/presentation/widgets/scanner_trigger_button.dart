import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../../barcode/presentation/screens/barcode_scanner_screen.dart';
import '../controllers/pos_controller.dart';

class ScannerTriggerButton extends ConsumerWidget {
  const ScannerTriggerButton({
    super.key,
    this.showIconOnly = false,
  });

  final bool showIconOnly;

  Future<void> _openScanner(BuildContext context, WidgetRef ref) async {
    final barcode = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => const BarcodeScannerScreen(isPopRequired: true),
    );

    if (barcode != null) {
      final posNotifier = ref.read(posControllerProvider.notifier);
      final product = await posNotifier.findProductByBarcode(barcode);

      if (product != null) {
        posNotifier.addToCart(product);
        // Optionally reopen scanner for "one after another" scanning
        // or just let them click scan again. The user said "one after another",
        // so maybe a continuous mode is better. But let's start with this.
      } else {
        if (context.mounted) {
          context.showSnakbar(
            'المنتج غير موجود في المستودع',
            type: SnackBarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomButton(
      child: showIconOnly
          ? const Icon(Icons.qr_code_scanner)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner),
                SizedBox(width: 8),
                Text('مسح ضوئي للباركود'),
              ],
            ),
      onPressed: () => _openScanner(context, ref),
    );
  }
}
