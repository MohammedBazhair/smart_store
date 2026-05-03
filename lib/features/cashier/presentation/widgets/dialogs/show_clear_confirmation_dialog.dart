import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import '../../controllers/pos_providers.dart';

void showClearConfirmation(
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (context) => const ClearCartConfirmationDialog(),
  );
}

class ClearCartConfirmationDialog extends ConsumerWidget {
  const ClearCartConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return DeleteConfirmationDialog(
      title: 'تفريغ السلة',
      description: 'هل أنت متأكد من مسح جميع المنتجات من السلة؟',
      cancelButtonText: 'تراجع',
      confirmButtonText: 'مسح السلة',
      onConfirmPressed: () {
        ref.read(posControllerProvider.notifier).clearCart();
        context.pop();
      },
    );
  }

}
