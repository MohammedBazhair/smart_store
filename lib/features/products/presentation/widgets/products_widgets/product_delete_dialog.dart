import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/utils/result.dart';
import '../../../../../shared/presentation/theme/app_theme.dart';
import '../../../domain/product.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/product_provider.dart';

class ProductDeleteDialog extends ConsumerWidget {
  const ProductDeleteDialog({
    super.key,
    required this.product,
  });
  final Product product;

  String get productName => product.name;

  @override
  Widget build(BuildContext context, ref) {
    return AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text('هل أنت متأكد من حذف "$productName"'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            final controller = ref.read(productControllerProvider.notifier);

            final result = await controller.deleteProduct(product.id!);

            if (!context.mounted) return;

            if (result is SuccessState<void>) {
              context.showSnakbar('تم الحذف بنجاح');
              ref.invalidate(productsProvider);
            } else if (result is ErrorState<void>) {
              context.showSnakbar(result.message);
            }
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          child: const Text('حذف'),
        ),
      ],
    );
  }
}
