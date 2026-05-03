import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/screen/dashboard_screen.dart';
import '../../../../../core/shared/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import '../../../../../errors/result.dart';
import '../../controllers/product_provider.dart';

final _loadingProvider = StateProvider((ref) => false);

Future<void> showDeleteProductDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => const DeleteProductDialog(),
  );
}

class DeleteProductDialog extends ConsumerWidget {
  const DeleteProductDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final product = ref.watch(currentProductProvider);
    final isLoading = ref.watch(_loadingProvider);

    final description = '''
هل أنت متأكد أنك تريد حذف الـ 
${product.value?.globalProduct.name ?? ''}
لا يمكنك التراجع عن هذه العملية
''';
    return DeleteConfirmationDialog(
      title: 'تأكيد حذف منتج',
      description: description,
      descriptionAlign: TextAlign.center,
      isLoading: isLoading,
      cancelButtonText: 'تراجع',
      confirmButtonText: 'حذف',
      onConfirmPressed: () async {
        if (product.value == null) return;
        ref.read(_loadingProvider.notifier).state = true;
        final result = await ref
            .read(productControllerProvider.notifier)
            .deleteProduct(product.value!);

        ref.read(_loadingProvider.notifier).state = false;

        if (result is ErrorState<void>) {
          context.showSnakbar(
            result.message,
            type: SnackBarType.error,
          );
          return context.pop();
        }

        if (result is SuccessState<void>) {
          context.showSnakbar(
            'تم حذف المنتج بنجاح',
            type: SnackBarType.success,
          );

          await context.pushAndRemoveUntilTo(
            const DashboardScreen(),
          );
        }
      },
    );
  }
}
