import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../../settings/domain/entities/currence_code.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import 'scanner_trigger_button.dart';

class PosSummaryFooter extends StatelessWidget {
  const PosSummaryFooter({
    super.key,
    required this.totalPrice,
    required this.isLoading,
    required this.onCheckout,
  });
  final double totalPrice;
  final bool isLoading;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 25,
        children: [
          Row(
            spacing: 12,
            children: [
              const Text(
                'المبلغ \nالإجمالي:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalPrice.formatDouble,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final currency = ref
                                  .watch(settingsControllerProvider)
                                  .value
                                  ?.defaultCurrency ??
                              CurrencyCode.theDefault;
                          return Text(
                            currency.label,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
                  child: CustomButton(
                    onPressed: isLoading ? null : onCheckout,
                    buttonStyle: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                    ),
                    child: isLoading
                        ? const ThreeDotsLoading(dotColor: Colors.white)
                        : const Text(
                            'شراء المنتجات',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const Expanded(
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
