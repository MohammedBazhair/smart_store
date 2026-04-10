import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../controllers/pos_providers.dart';

void showClearConfirmation(
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (context) => const ProviderScope(child: ClearConfirmationDialog()),
  );
}

class ClearConfirmationDialog extends StatelessWidget {
  const ClearConfirmationDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تفريغ السلة'),
      content: const Text('هل أنت متأكد من مسح جميع المنتجات من السلة؟'),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: const Text('تراجع'),
        ),
        Consumer(
          builder: (context, ref, child) => TextButton(
            onPressed: () {
              ref.read(posControllerProvider.notifier).clearCart();
              context.pop();
            },
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
