import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/presentation/widgets/common/conditional_builder.dart';
import '../../../../shared/presentation/widgets/common/loading_widget.dart';
import '../../domain/settings.dart';
import '../controllers/settings_controller.dart';

final _isWritingOnField = StateProvider.autoDispose((_) => false);

class CurrencySettingsCard extends ConsumerStatefulWidget {
  const CurrencySettingsCard({
    super.key,
    required this.settings,
    this.exchangeRateController,
  });
  final Settings settings;
  final TextEditingController? exchangeRateController;

  @override
  ConsumerState<CurrencySettingsCard> createState() =>
      _CurrencySettingsCardState();
}

class _CurrencySettingsCardState extends ConsumerState<CurrencySettingsCard> {
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.exchangeRateController?.text =
        widget.settings.exchangeRate.formatDouble();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _showMessages(Settings updatedSettings) async {
    final controller = ref.read(settingsControllerProvider.notifier);

    final result = await controller.updateSettings(updatedSettings);

    if (!context.mounted) return;

    if (result is SuccessState<void>) {
      context.showSnakbar('تم تحديث الإعدادات', type: SnackBarType.success);
    } else if (result is ErrorState<void>) {
      context.showSnakbar(result.message, type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            DropdownButtonFormField<Currency>(
              value: widget.settings.defaultCurrency,
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
                    widget.settings.copyWith(defaultCurrency: value);

                await _showMessages(updatedSettings);
              },
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (_, ref, __) {
                final isLoading = ref.watch(_isWritingOnField);

                return TextField(
                  controller: widget.exchangeRateController,
                  decoration: InputDecoration(
                    labelText: 'سعر الصرف',
                    helperText:
                        '1 ريال سعودي = ${widget.exchangeRateController?.text} ريال يمني',
                    helperStyle: const TextStyle(height: 2),
                    suffix: ConditionalBuilder(
                      condition: isLoading,
                      builder: (_) => const LoadingWidget(
                        size: 20,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    ref.read(_isWritingOnField.notifier).state = true;
                    _debounceTimer?.cancel();

                    _debounceTimer =
                        Timer(const Duration(milliseconds: 1350), () async {
                      final rate = double.tryParse(value);
                      if (rate == null || rate <= 0) return;

                      final updatedSettings =
                          widget.settings.copyWith(exchangeRate: rate);

                      ref.read(_isWritingOnField.notifier).state = false;
                      await _showMessages(updatedSettings);
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
