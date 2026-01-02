import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../core/utils/result.dart';
import '../../../../shared/presentation/theme/app_theme.dart';
import '../../../alerts/presentation/controllers/alert_service.dart';
import '../../domain/product.dart';
import '../controllers/product_controller.dart';
import 'add_product_screen.dart';

/// شاشة تفاصيل المنتج
class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = date_utils.DateUtils.daysUntilExpiry(product.expiryDate);
    final isExpired = date_utils.DateUtils.isExpired(product.expiryDate);
    final statusColor = isExpired
        ? AppTheme.expiredColor
        : days <= 7
            ? AppTheme.nearExpiryColor
            : AppTheme.validColor;

    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () async{
          await ref.read(alertServiceProvider).testScheduledNotification();
        },
        child: const Text('اختبار تنبيه انتهاء المنتج'),
      ),
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة المعلومات الرئيسية
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isExpired
                              ? 'منتهي'
                              : days <= 7
                                  ? 'قريب من الانتهاء'
                                  : 'صالح',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.inventory_2,
                    'الكمية',
                    product.quantity.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.category,
                    'الفئة',
                    product.category.label,
                  ),
                  if (product.barcode != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.qr_code,
                      'كود المنتج',
                      product.barcode!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'تاريخ الانتهاء',
                    DateFormat('yyyy-MM-dd').format(product.expiryDate),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.schedule,
                    'الأيام المتبقية',
                    isExpired ? 'منتهي' : '$days ${days == 1 ? 'يوم' : 'أيام'}',
                  ),
                  if (product.notes != null && product.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.note,
                      'ملاحظات',
                      product.notes!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updatedProduct = await context.pushTo<Product?>(
                      AddProductScreen(
                        product: product,
                      ),
                    );
                    if (updatedProduct == null) return;
                    await ref
                        .read(productControllerProvider.notifier)
                        .updateProduct(
                          oldProduct: product,
                          newProduct: updatedProduct,
                        );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(context, ref),
                  icon: const Icon(Icons.delete),
                  label: const Text('حذف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = ref.read(productControllerProvider.notifier);
              final result = await controller.deleteProduct(product.id!);

              if (!context.mounted) return;

              Navigator.pop(context);
              if (result is SuccessState<void>) {
                if (!context.mounted) return;
                Navigator.pop(context);
                context.showSnakbar('تم الحذف بنجاح');
              } else if (result is ErrorState<void>) {
                if (!context.mounted) return;
                context.showSnakbar(result.message);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
