import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product_details.dart';
import '../../controllers/product_provider.dart';


class ProductCategoryDropdown extends ConsumerWidget {
  const ProductCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final Category value;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context,ref) {
    return DropdownButtonFormField<Category>(
      value: value,
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.category],
      decoration: const InputDecoration(
        labelText: 'الفئة *',
        prefixIcon: Icon(Icons.category),
        helperText: '',
      ),
      items:Category.values.map((category) {
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
