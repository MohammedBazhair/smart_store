import 'package:flutter/material.dart';

class ProductNameField extends StatelessWidget {
  const ProductNameField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,

      decoration: const InputDecoration(
        labelText: 'اسم المنتج *',
        prefixIcon: Icon(Icons.inventory_2),
              helperText: '',

      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال اسم المنتج';
        }
        return null;
      },
    );
  }
}
