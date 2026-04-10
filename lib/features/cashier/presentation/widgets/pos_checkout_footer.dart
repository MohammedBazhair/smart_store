import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../settings/domain/entities/currence_code.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../controllers/pos_providers.dart';
import 'checkout_button.dart';
import 'scanner_trigger_button.dart';

class PosCheckoutFooter extends ConsumerWidget {
  const PosCheckoutFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 25,
        children: [
          Row(
            spacing: 12,
            children: [
              Text(
                'إجمالي الطلب',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                child: _CartTotalView(),
              ),
            ],
          ),
          SizedBox(
            height: 50,
            child: Row(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: CheckoutButton(),
                ),
                Expanded(
                  child: ScannerTriggerButton(
                    showIconOnly: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartTotalView extends ConsumerWidget {
  const _CartTotalView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPrice = ref.watch(
      posControllerProvider.select((state) => state.totalPrice),
    );

    final result = ref.read(settingsControllerProvider.notifier).convert(
          price: totalPrice,
          from: CurrencyCode.theDefault,
        );

    final convertedTotalPrice = result.price;
    final currency = result.currency;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            convertedTotalPrice.formatDouble,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            currency.label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

