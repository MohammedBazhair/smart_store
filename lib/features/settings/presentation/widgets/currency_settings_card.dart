import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
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
              'إعدادات العملة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CurrencyCode>(
              value: settings.defaultCurrency,
              decoration: const InputDecoration(labelText: 'العملة الافتراضية'),
              items: CurrencyCode.values
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // قيمة سعر الصرف
          Text(
            '${currentExchangeRate.rateToBase}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // العملة الثانوية
          Text(
            currentExchangeRate.currency.label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          // الوصف أو label
          Text(
            'سعر 1 ${currentExchangeRate.currency.label} مقابل ${primaryCurrency.label}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
