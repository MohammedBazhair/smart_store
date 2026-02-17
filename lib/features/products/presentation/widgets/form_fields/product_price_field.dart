import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/enums.dart';
import '../../../domain/entities/product_details.dart';
import '../../controllers/product_provider.dart';

class ProductPriceField extends ConsumerWidget {
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
  Widget build(BuildContext context, ref) {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: TextFormField(
            focusNode: ref.read(focusNodesProvider)[ProductDetailsType.price],
            controller: controller,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d+\.?\d{0,2}'),
              ),
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
