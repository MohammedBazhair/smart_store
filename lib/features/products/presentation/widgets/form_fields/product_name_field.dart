import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/product_details.dart';
import '../../controllers/product_provider.dart';


class ProductNameField extends ConsumerWidget {
  const ProductNameField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, ref) {
    return TextFormField(
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.name],
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
