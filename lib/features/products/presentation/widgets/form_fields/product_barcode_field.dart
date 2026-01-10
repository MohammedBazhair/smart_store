import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/product_details.dart';
import '../../controllers/product_provider.dart';

class ProductBarcodeField extends ConsumerWidget {
  const ProductBarcodeField({
    super.key,
    required this.controller,
    required this.onScan,
  });
  final TextEditingController controller;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context, ref) {
    return TextFormField(
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.barcode],
      controller: controller,
      textInputAction: TextInputAction.go,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onFieldSubmitted: (value) => onScan(),
      decoration: InputDecoration(
        labelText: 'كود المنتج (باركود)',
        prefixIcon: const Icon(Icons.qr_code),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: onScan,
        ),
        helperText: '',
      ),
      validator: (value) {
        final reg = RegExp(r'^\d+$');
        if (value == null || value.trim().isEmpty) return null;

        if (reg.hasMatch(value)) return null;
        return 'لا يمكن أن يحتوي كود الباركود على حروف. استعمل أرقام فقط';
      },
    );
  }
}
