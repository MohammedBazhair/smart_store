import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/utils/result.dart';
import '../../../../../shared/presentation/theme/app_theme.dart';
import '../../../domain/product.dart';
import '../../controllers/product_controller.dart';

class DeleteProductDialog extends ConsumerWidget {
  const DeleteProductDialog({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text('هل تريد حذف "${product.name}"؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          onPressed: () async {
            final result = await ref
                .read(productControllerProvider.notifier)
                .deleteProduct(product.id!);

            if (!context.mounted) return;
            Navigator.pop(context);

            result is SuccessState
                ? context.showSnakbar('تم الحذف بنجاح')
                : context.showSnakbar((result as ErrorState).message);

            if (result is SuccessState) Navigator.pop(context);
          },
          child: const Text('حذف'),
        ),
      ],
    );
  }
}
