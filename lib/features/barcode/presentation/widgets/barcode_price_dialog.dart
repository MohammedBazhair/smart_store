import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../shared/presentation/theme/app_theme.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../../domain/barcode_scan_result.dart';
import 'animated_price.dart';

Future<void> showBarcodePriceDialog({
  required BuildContext context,
  required WidgetRef ref,
  required BarcodeScanResult result,
}) async {
  final settingsAsync = ref.read(appSettingsProvider);

  await showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              AppTheme.primaryColor.withOpacity(0.15),
            ],
            stops: const [0.5, 0.8],
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.01),
              blurRadius: 5,
              spreadRadius: 1,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: settingsAsync.when(
          data: (settings) {
            final product = result.product;

            if (product == null) {
              return const Center(
                child: Text('هذا المنتج غير موجود'),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // عنوان
                Text(
                  'المنتج',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 12),

                // اسم المنتج (ثانوي)
                Text(
                  product.name ,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),

                const SizedBox(height: 24),

                AnimatedPrice(product),

                // التحويل (إن وجد)
                if (product.currency != settings.defaultCurrency) ...[
                  const SizedBox(height: 12),
                  Text(
                    '≈ ${_convertPrice(
                      price: product.price,
                      from: product.currency,
                      to: settings.defaultCurrency,
                      rate: settings.exchangeRate,
                    )} ${settings.defaultCurrency.label}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],

                const SizedBox(height: 24),

                // زر الإغلاق
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => const Text('خطأ في تحميل الإعدادات'),
        ),
      ),
    ),
  );
}

String _convertPrice({
  required double price,
  required Currency from,
  required Currency to,
  required double rate,
}) {
  if (from == Currency.SAR && to == Currency.YER) {
    return (price * rate).toStringAsFixed(2);
  } else if (from == Currency.YER && to == Currency.SAR) {
    return (price / rate).toStringAsFixed(2);
  }
  return price.toStringAsFixed(2);
}
