import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/product_details.dart';
import '../../screens/add_product_screen.dart';

class ProductQuantityField extends ConsumerWidget {
  const ProductQuantityField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, ref) {
    return TextFormField(
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.quantity],
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
