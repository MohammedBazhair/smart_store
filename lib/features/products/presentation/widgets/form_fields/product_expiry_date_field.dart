import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/product_details.dart';
import '../../screens/add_product_screen.dart';

class ProductExpiryDateField extends ConsumerWidget {
  const ProductExpiryDateField({
    super.key,
    required this.controller,
    required this.onSelectDate,
  });
  final TextEditingController controller;
  final VoidCallback onSelectDate;

  @override
  Widget build(BuildContext context,ref) {
    return TextFormField(
      controller: controller,
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.expiryDate],
      keyboardType: TextInputType.none,
      decoration: const InputDecoration(
        labelText: 'تاريخ الانتهاء *',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(Icons.calendar_today),
        helperText: '',
        hint: Text('اختر التاريخ'),
      ),
       validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال تاريخ انتهاء المنتج';
        }
        return null;
      },
    );
  }
}
