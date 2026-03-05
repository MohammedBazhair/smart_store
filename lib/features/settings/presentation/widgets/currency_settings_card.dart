import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/currence_code.dart';
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
            const TextField(
              decoration: InputDecoration(
                labelText: 'سعر الصرف',
                helperStyle: TextStyle(height: 2),
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
