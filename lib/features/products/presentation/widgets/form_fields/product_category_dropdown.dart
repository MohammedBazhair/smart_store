import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/enums.dart';
import '../../../domain/product_details.dart';
import '../../screens/add_product_screen.dart';

class ProductCategoryDropdown extends ConsumerWidget {
  const ProductCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final ProductCategory value;
  final ValueChanged<ProductCategory?> onChanged;

  @override
  Widget build(BuildContext context,ref) {
    return DropdownButtonFormField<ProductCategory>(
      value: value,
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.category],
      decoration: const InputDecoration(
        labelText: 'الفئة *',
        prefixIcon: Icon(Icons.category),
        helperText: '',
      ),
      items: ProductCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.label),
        );
      }).toList(),
      
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'يرجى اختيار فئة المنتج';
        }
        return null;
      },
    );
  }
}
