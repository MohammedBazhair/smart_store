import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/settings.dart';
import '../controllers/settings_controller.dart';

class CurrencySettingsCard extends ConsumerWidget {
  const CurrencySettingsCard({
    super.key,
    required this.settings,
    required this.exchangeRateController,
  });
  final Settings settings;
  final TextEditingController exchangeRateController;

  Future<void> _showMessages(
    WidgetRef ref,
    BuildContext context,
    Settings updatedSettings,
  ) async {
    final controller = ref.read(settingsControllerProvider.notifier);

    final result = await controller.updateSettings(updatedSettings);

    if (!context.mounted) return;

    if (result is SuccessState<void>) {
      context.showSnakbar('تم تحديث الإعدادات');
    } else if (result is ErrorState<void>) {
      context.showSnakbar(result.message);
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    exchangeRateController.text = settings.exchangeRate.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات العملة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Currency>(
              value: settings.defaultCurrency,
              decoration: const InputDecoration(labelText: 'العملة الافتراضية'),
              items: Currency.values
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

                await _showMessages(ref, context, updatedSettings);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: exchangeRateController,
              decoration: const InputDecoration(
                labelText: 'سعر الصرف (1 SAR = ? YER)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) async {
                final rate = double.tryParse(value);
                if (rate == null || rate <= 0) return;

                final updatedSettings = settings.copyWith(exchangeRate: rate);

                await _showMessages(ref, context, updatedSettings);
              },
            ),
          ],
        ),
      ),
    );
  }
}
