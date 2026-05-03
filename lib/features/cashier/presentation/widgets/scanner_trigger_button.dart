import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../../barcode/domain/barcode_scan_result.dart';
import '../../../barcode/presentation/screens/barcode_scanner_screen.dart';
import '../../../products/domain/entities/store_product.dart';
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
      final result = await showModalBottomSheet<BarcodeScanResult?>(
        context: navigator.context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => const FractionallySizedBox(
          heightFactor: 0.6,
          child: BarcodeScannerScreen(
            isPopRequired: true,
            isBottomSheet: true,
          ),
        ),
      );
      if (result == null || !navigator.mounted) break;

      final product = result.product;

      if (product is StoreProduct) {
        posNotifier.addToCart(product);
        // Delay to allow the prbottom sheet to close and native resources to release
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
