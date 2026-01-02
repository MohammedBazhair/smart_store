import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/enums.dart';

class ProductPriceField extends StatelessWidget {
  const ProductPriceField({
    super.key,
    required this.controller,
    required this.onCurrencyChanged,
    required this.currency,
  });
  final TextEditingController controller;
  final ValueChanged<Currency?> onCurrencyChanged;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'سعر المنتج *',
              prefixIcon: Icon(Icons.price_change_rounded),
              helperText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال سعر المنتج';
              }
              return null;
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<Currency>(
            value: currency,
            decoration: const InputDecoration(
              labelText: 'العملة *',
              prefixIcon: Icon(Icons.price_check_rounded),
              helperText: '',
            ),
            items: Currency.values.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency.label),
              );
            }).toList(),
            onChanged: onCurrencyChanged,
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار عملة المنتج';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
