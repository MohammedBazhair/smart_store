import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../controllers/pos_controller.dart';
import '../widgets/pos_summary_footer.dart';
import '../widgets/pos_table.dart';
import '../widgets/scanner_trigger_button.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posControllerProvider);
    final posNotifier = ref.read(posControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحاسب الصغير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {
              if (state.cartItems.isNotEmpty) {
                _showClearConfirmation(context, posNotifier);
              }
            },
          ),
        ],
      ),
      body: state.cartItems.isEmpty
          ? const _BuildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: PosTable(cartItems: state.cartItems.values.toList()),
                ),
                if (state.cartItems.isNotEmpty)
                  PosSummaryFooter(
                    totalPrice: state.totalPrice,
                    isLoading: state.isLoading,
                    onCheckout: () => _handleCheckout(context, ref),
                  ),
              ],
            ),
    );
  }

  void _showClearConfirmation(BuildContext context, PosController notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفريغ السلة'),
        content: const Text('هل أنت متأكد من مسح جميع المنتجات من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              notifier.clearCart();
              Navigator.pop(context);
            },
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(posControllerProvider.notifier).checkout();
    if (success && context.mounted) {
      _showInvoiceDialog(context, ref);
      ref.read(posControllerProvider.notifier).clearCart();
    } else if (!success && context.mounted) {
      final error = ref.read(posControllerProvider).errorMessage;
      if (error != null) {
        context.showSnakbar(error, type: SnackBarType.error);
      }
    }
  }

  void _showInvoiceDialog(BuildContext context, WidgetRef ref) {
    final cartItems = ref.read(posControllerProvider).cartItems;
    final total = ref.read(posControllerProvider).totalPrice;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('فاتورة مبيعات')),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              ...cartItems.values.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.product.globalProduct.name} x${item.quantity}',
                      ),
                      Text('${item.subtotal}'),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الإجمالي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$total',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('تمت العملية بنجاح وخصم الكميات من المخزن'),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildEmptyState extends StatelessWidget {
  const _BuildEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 22,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: AppTheme.primaryColor.withOpacity(0.8),
            ),
          ),
          const Text(
            'لا توجد منتجات بعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const ScannerTriggerButton(),
          const Text(
            'ابدأ بمسح المنتجات لإضافتها إلى السلة',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
