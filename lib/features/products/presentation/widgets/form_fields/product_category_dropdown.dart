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
  Widget build(BuildContext context, ref) {
    final categories =
        ref.watch(productControllerProvider.select((s) => s.categories));
    return DropdownMenuFormField<Category>(
      initialSelection: value,
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.category],
      expandedInsets: const EdgeInsets.all(0),
      alignmentOffset: const Offset(0, -20),
      menuHeight: 200,
      leadingIcon: const Icon(Icons.category),
      trailingIcon: const Icon(Icons.keyboard_arrow_down),
      inputDecorationTheme: const InputDecorationThemeData(
        fillColor: Colors.white,
        filled: true,
      ),
      hintText: 'اختر فئة *',
      helperText: '',
      label: const Text('الفئة'),
      selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up),
      dropdownMenuEntries: categories.map((category) {
        return DropdownMenuEntry(
          value: category,
          label: category.name,
        );
      }).toList(),
      onSelected: onChanged,
      validator: (value) {
        if (value == null) {
          return 'يرجى اختيار فئة المنتج';
        }
        return null;
      },
    );
  }
}
