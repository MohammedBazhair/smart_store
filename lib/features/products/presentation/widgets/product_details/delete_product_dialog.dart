import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/screen/dashboard_screen.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 25,
          children: [
            // العنوان
            const Text(
              'تأكيد حذف منتج',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            Text.rich(
              TextSpan(
                text: 'هل أنت متأكد أنك تريد حذف الـ',
                children: [
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: product?.globalProduct.name ?? '',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' \n لا يمكنك التراجع عن هذه العملية'),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.6,
                letterSpacing: 0.7,
              ),
            ),

            // الأزرار
            Row(
              spacing: 15,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:isLoading? null: () async {
                      if (product == null) return;
                      ref.read(_loadingProvider.notifier).state = true;
                      final result = await ref
                          .read(productControllerProvider.notifier)
                          .deleteProduct(product);

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

                        await context
                            .pushAndRemoveUntilTo(const DashboardScreen());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.red.shade400,
                      shadowColor: const Color.fromARGB(110, 255, 136, 134),
                    ),
                    child: isLoading
                        ? const ThreeDotsLoading(dotSize: 5)
                        : const Text(
                            'حذف',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: context.pop,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'تراجع',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
