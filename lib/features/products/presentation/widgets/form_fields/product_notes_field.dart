import 'package:flutter/material.dart';

class ProductNotesField extends StatelessWidget {
  const ProductNotesField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'ملاحظات',
      ),
      maxLines: 3,
    );
  }
}
