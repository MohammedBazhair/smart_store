import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/product_details.dart';
import '../../controllers/product_provider.dart';

class ProductNotesField extends ConsumerWidget {
  const ProductNotesField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context,ref) {
    return TextFormField(
      controller: controller,
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.notes],
      decoration: const InputDecoration(
        labelText: 'ملاحظات',
      ),
      maxLines: 3,
    );
  }
}
