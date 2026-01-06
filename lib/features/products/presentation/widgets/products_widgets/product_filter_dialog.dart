import 'package:flutter/material.dart';

import '../../../../../core/constants/enums.dart';

class ProductFilterDialog extends StatelessWidget {
  const ProductFilterDialog({
    super.key,
    required this.initialCategory,
    required this.onApply,
  });
  final ProductCategory? initialCategory;
  final ValueChanged<ProductCategory?> onApply;

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
              
              ...ProductCategory.values.map(
                (category) => RadioListTile<ProductCategory?>(
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
