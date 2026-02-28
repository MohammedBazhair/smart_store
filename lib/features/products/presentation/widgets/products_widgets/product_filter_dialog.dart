import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/category.dart';
import '../../controllers/product_provider.dart';

class ProductFilterDialog extends ConsumerWidget {
  const ProductFilterDialog({
    super.key,
    required this.initialCategory,
    required this.onApply,
  });
  final Category? initialCategory;
  final ValueChanged<Category?> onApply;

  @override
  Widget build(BuildContext context, ref) {
    final categories =
        ref.watch(productControllerProvider.select((s) => s.categories));
    return AlertDialog(
      title: const Text(
        'تصفية حسب الفئة',
        textAlign: TextAlign.center,
      ),
      insetPadding: const EdgeInsets.symmetric(vertical: 150, horizontal: 12),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories
                .map(
                  (category) => RadioListTile<Category?>(
                    title: Text(category.name),
                    value: category,
                    groupValue: initialCategory,
                    onChanged: (value) {
                      onApply(value);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}
