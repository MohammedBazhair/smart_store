import 'package:flutter/material.dart';

import '../../../../../core/constants/enums.dart';

class ProductCategoryDropdown extends StatelessWidget {
  const ProductCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final ProductCategory value;
  final ValueChanged<ProductCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProductCategory>(
      value: value,
      
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
