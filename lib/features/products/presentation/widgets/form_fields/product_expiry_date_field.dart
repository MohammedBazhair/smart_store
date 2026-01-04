import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/product_details.dart';
import '../../controllers/product_provider.dart';

class ProductExpiryDateField extends ConsumerWidget {
  const ProductExpiryDateField({
    super.key,
    required this.controller,
    required this.onSelectDate,
  });
  final TextEditingController controller;
  final VoidCallback onSelectDate;

  @override
  Widget build(BuildContext context, ref) {
    return TextFormField(
      controller: controller,
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.expiryDate],
      readOnly: true,
      keyboardType: TextInputType.none,
      onTap: onSelectDate,
      decoration: const InputDecoration(
        labelText: 'تاريخ الانتهاء',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(Icons.calendar_today),
        helperText: '',
        hint: Text('اختر التاريخ'),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final splites = value.split('-');

        if (splites.length != 3) return 'يجب أن يكون التاريخ بصيغة 20-2-2026';
        final year = splites[0];
        final month = splites[1];
        final day = splites[2];

        if (year.length != 4 || day.length != 2 && month.length != 2) {
          return 'يجب أن تكون خانة اليوم والشهر مكونة من رقمين فقط. وخانة الارقام مكونة من اربع ارقام';
        }
        return null;
      },
    );
  }
}
