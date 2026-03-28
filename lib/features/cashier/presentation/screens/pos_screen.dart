import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../barcode/presentation/screens/barcode_scanner_screen.dart';
import '../controllers/pos_controller.dart';
import '../widgets/pos_item_row.dart';
import '../widgets/pos_summary_footer.dart';
import '../widgets/pos_table_header.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

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
      body: Column(
        children: [
          // Scanner Trigger
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _openScanner(context, ref),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'مسح منتج جديد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const PosTableHeader(),

          Expanded(
            child: state.cartItems.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      return PosItemRow(item: state.cartItems[index]);
                    },
                  ),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'السلة فارغة، ابدأ بمسح المنتجات',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _openScanner(BuildContext context, WidgetRef ref) async {
    // We use the existing BarcodeScannerScreen with isPopRequired: true
    // In a real app, we might want a continuous scanner, but for now this works.
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerScreen(isPopRequired: true),
      ),
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
              ...cartItems.map(
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
