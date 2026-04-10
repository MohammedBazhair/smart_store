import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../../barcode/presentation/screens/barcode_scanner_screen.dart';
import '../controllers/pos_providers.dart';

class ScannerTriggerButton extends ConsumerWidget {
  const ScannerTriggerButton({
    super.key,
    this.showIconOnly = false,
  });

  final bool showIconOnly;

  Future<void> _openScanner(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final posNotifier = ref.read(posControllerProvider.notifier);

    while (true) {
      if (!navigator.mounted) break;
      final barcode = await showModalBottomSheet<String?>(
        context: navigator.context,
        builder: (context) => const BarcodeScannerScreen(isPopRequired: true),
      );

      if (barcode == null || !navigator.mounted) break;

      final product = await posNotifier.findProductByBarcode(barcode);

      if (product != null) {
        posNotifier.addToCart(product);
        // Delay to allow the bottom sheet to close and native resources to release
        await Future.delayed(const Duration(seconds: 1));
        continue;
      } else {
        navigator.context.showSnakbar(
          'المنتج غير موجود في المستودع',
          type: SnackBarType.error,
        );

        break;
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
      onPressed: () {
        _openScanner(context, ref);
      },
    );
  }
}
