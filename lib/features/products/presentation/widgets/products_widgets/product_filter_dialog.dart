import 'package:flutter/material.dart';

import '../../../domain/entities/category.dart';

class ProductFilterDialog extends StatelessWidget {
  const ProductFilterDialog({
    super.key,
    required this.initialCategory,
    required this.onApply,
  });
  final Category? initialCategory;
  final ValueChanged<Category?> onApply;

  @override
  Widget build(BuildContext context) {
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
            children: [
              
              ...Category.values.map(
                (category) => RadioListTile<Category?>(
                  title: Text(category.label),
                  value: category,
                  groupValue: initialCategory,
                  onChanged: (value) {
                    onApply(value);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
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
