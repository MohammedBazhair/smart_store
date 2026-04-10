import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../controllers/pos_providers.dart';
import 'dialogs/show_invoice_dialog.dart';

class CheckoutButton extends ConsumerWidget {
  const CheckoutButton({super.key});

  Future<void> _processCheckout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(posControllerProvider.notifier).checkout();
    if (success && context.mounted) {
      // ignore: unawaited_futures
      ref.read(audioControllerProvider.notifier).playSuccessResult();
      await showInvoiceDialog(context);

      ref.read(posControllerProvider.notifier).clearCart();
    } else if (!success && context.mounted) {
      final error = ref.read(posControllerProvider).errorMessage;
      if (error != null) {
        context.showSnakbar(error, type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    final isLoading = ref.watch(
      posControllerProvider.select((state) => state.isLoading),
    );

    return CustomButton(
      onPressed: isLoading ? null : () => _processCheckout(context, ref),
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.successColor,
      ),
      child: isLoading
          ? const ThreeDotsLoading(dotColor: Colors.white)
          : const Text(
              'إتمام الدفع',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
