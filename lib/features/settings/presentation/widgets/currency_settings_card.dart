import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/currence_code.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/entities/settings.dart';
import '../controllers/settings_provider.dart';

class CurrencySettingsCard extends ConsumerWidget {
  const CurrencySettingsCard({
    super.key,
    required this.settings,
  });
  final Settings settings;

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العملة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            DropdownMenuFormField<CurrencyCode>(
              initialSelection: settings.defaultCurrency,
              label: const Text('العملة الافتراضية'),
              expandedInsets: const EdgeInsets.all(0),
              menuHeight: 200,
              enableSearch: false,
              menuStyle: const MenuStyle(
                elevation: WidgetStatePropertyAll(2),
              ),
              trailingIcon: const Icon(Icons.keyboard_arrow_down),
              selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up),
              dropdownMenuEntries: CurrencyCode.values
                  .map(
                    (currency) => DropdownMenuEntry(
                      value: currency,
                      label: currency.label,
                    ),
                  )
                  .toList(),
              inputDecorationTheme: const InputDecorationThemeData(
                fillColor: Colors.white,
                filled: true,
              ),
              hintText: 'اختر فئة *',
              onSelected: (value) async {
                if (value == null) return;
                final updatedSettings =
                    settings.copyWith(defaultCurrency: value);

                final controller =
                    ref.read(settingsControllerProvider.notifier);

                final result = await controller.updateSettings(updatedSettings);

                if (!context.mounted) return;

                if (result is SuccessState<void>) {
                  context.showSnakbar(
                    'تم تحديث الإعدادات',
                    type: SnackBarType.success,
                  );
                } else if (result is ErrorState<void>) {
                  context.showSnakbar(result.message, type: SnackBarType.error);
                }
              },
            ),
            const SizedBox(height: 24),
            ExchangeRateWidget(
              currentExchangeRate: settings.defaultExchangeRate,
            ),
          ],
        ),
      ),
    );
  }
}

class ExchangeRateWidget extends StatelessWidget {
  const ExchangeRateWidget({
    super.key,
    required this.currentExchangeRate,
  });

  final ExchangeRate currentExchangeRate;

  CurrencyCode get primaryCurrency => CurrencyCode.theDefault;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.currency_exchange,
              color: AppTheme.primaryColor,
              size: 15,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              'سعر الصرف الحالي',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'مباشر',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Main Exchange Rate Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // العملة المصدر
            Expanded(
              child: Column(
                children: [
                  const Text(
                    '1',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    currentExchangeRate.currency.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      height: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // أيقونة التحويل
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.primaryColor.withOpacity(0.5),
              size: 30,
            ),

            const SizedBox(width: 8),

            // العملة الهدف
            Expanded(
              child: Column(
                children: [
                  Text(
                    currentExchangeRate.rateToBase.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    primaryCurrency.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      height: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Footer Info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 5),
            const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'اسحب الشاشة للاسفل لتحديث سعر الصرف',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
