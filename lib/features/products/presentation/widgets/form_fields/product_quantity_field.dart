import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductQuantityField extends StatelessWidget {
  const ProductQuantityField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'الكمية',
        prefixIcon: Icon(Icons.numbers),
        helperText: '',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
