import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../auth/presentation/widgets/custom_button.dart';
import '../../controllers/pos_providers.dart';
import '../quantity_wheel_selector.dart';

Future<void> showQuantitySelector(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return const ProviderScope(
        child: QuantitySelectorDialog(),
      );
    },
  );
}

class QuantitySelectorDialog extends StatelessWidget {
  const QuantitySelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer(
              builder: (_, ref, __) {
                final productName = ref.read(
                  quantitySelectionProvider.select((s) => s.productName),
                );
                return Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const QuantityWheelSelector(),
            const SizedBox(height: 24),
            CustomButton(
              buttonStyle: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF01B7C1),
              ),
              onPressed: context.pop,
              child: const Text(
                'تأكيد',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
