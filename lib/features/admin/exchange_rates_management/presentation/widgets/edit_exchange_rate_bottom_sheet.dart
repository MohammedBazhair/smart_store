import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/shared/presentation/widgets/common/bottom_sheet_handle.dart';
import '../../../../settings/domain/entities/exchange_rate.dart';
import '../providers/admin_exchange_rates_provider.dart';

Future<void> showEditExchangeRateBottomSheet({
  required BuildContext context,
  required ExchangeRate rate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return EditExchangeRateBottomSheet(
        rate: rate,
      );
    },
  );
}

class EditExchangeRateBottomSheet extends ConsumerStatefulWidget {
  const EditExchangeRateBottomSheet({
    super.key,
    required this.rate,
  });

  final ExchangeRate rate;

  @override
  ConsumerState<EditExchangeRateBottomSheet> createState() =>
      _EditExchangeRateBottomSheetState();
}

class _EditExchangeRateBottomSheetState
    extends ConsumerState<EditExchangeRateBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.rate.rateToBase.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final value = int.tryParse(_controller.text);

    if (value == null || value <= 0) {
      return;
    }

    Navigator.pop(context);

    await ref.read(adminExchangeRatesControllerProvider.notifier).updateRate(
          rate: widget.rate.copyWith(
            rateToBase: value,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          Text(
            'تعديل سعر الصرف',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primary.withOpacity(.06),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(widget.rate.currency.name),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'العملة: ${widget.rate.currency.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'سعر الصرف الجديد',
              hintText: 'أدخل سعر الصرف',
              prefixIcon: Icon(Icons.currency_exchange),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.save),
              label: const Text('حفظ التغييرات'),
            ),
          ),
        ],
      ),
    );
  }
}
