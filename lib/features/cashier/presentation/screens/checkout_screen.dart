import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/common_actions.dart';
import '../controllers/pos_providers.dart';
import '../widgets/dialogs/manage_quick_products_dialog.dart';
import '../widgets/dialogs/show_clear_confirmation_dialog.dart';
import '../widgets/pos_checkout_footer.dart';
import '../widgets/pos_table.dart';
import '../widgets/quick_products_section.dart';
import '../widgets/scanner_trigger_button.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحاسب الصغير'),
        actions: [
          const SettingsActonIcon(),
          IconButton(
            tooltip: 'تفريغ السلة',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {
              if (state.cartItems.isNotEmpty) {
                showClearConfirmation(context);
              }
            },
          ),
        ],
      ),
      body: state.cartItems.isEmpty
          ? const _BuildEmptyState()
          : Column(
              children: [
                const QuickProductsSection(),
                Expanded(
                  child: PosTable(cartItems: state.cartItems.values.toList()),
                ),
                if (state.cartItems.isNotEmpty) const PosCheckoutFooter(),
              ],
            ),
      floatingActionButton: state.cartItems.isEmpty
          ? FloatingActionButton(
              onPressed: () => showManageQuickProductsDialog(context),
              child: const Icon(Icons.bolt_outlined),
            )
          : null,
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
            'لا توجد منتجات في السلة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const ScannerTriggerButton(),
          const Text(
            'ابدأ بمسح المنتجات لإضافتها إلى السلة',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: const Row(
              spacing: 15,
              children: [
                Expanded(child: Divider()),
                Text('أو', style: TextStyle(color: AppTheme.textSecondary)),
                Expanded(child: Divider()),
              ],
            ),
          ),
          const Text(
            'اضغط على زر المنتجات السريعة ⚡\nلاختيار منتجاتك المفضلة وإضافتها للسلة',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 2),
          ),
        ],
      ),
    );
  }
}
