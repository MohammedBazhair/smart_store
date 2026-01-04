import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/presentation/theme/app_theme.dart';
import '../../../../shared/providers/repositories_provider.dart';
import '../../../products/domain/product.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../domain/alert.dart';
import '../controllers/alert_controller.dart';
import '../controllers/alert_provider.dart';

class AlertCard extends ConsumerWidget {
  const AlertCard({super.key, required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importanceColor = alert.importance == Priority.high
        ? AppTheme.errorColor
        : alert.importance == Priority.defaultPriority
            ? AppTheme.warningColor
            : AppTheme.primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: alert.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: importanceColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.warning,
            color: importanceColor,
          ),
        ),
        title: Text(
          alert.productName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (alert.expiryDate != null)
              Text(
                'ينتهي في ${DateFormat('yyyy-MM-dd').format(alert.expiryDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: importanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert.importance.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: importanceColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${alert.daysBeforeExpiry} أيام قبل الانتهاء',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            alert.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
          ),
          onPressed: () async {
            final controller = ref.read(alertControllerProvider.notifier);
            await controller.markAsRead(alert.id!);
            ref.invalidate(alertsProvider);
          },
        ),
        onTap: () async {
          final product = await ref
              .read(productRepositoryProvider)
              .getProductById(alert.productId);
          if (product is SuccessState<Product>) {
            await context.pushTo(
              ProductDetailsScreen(productId: product.data.id!),
            );
          } else {
            context.showSnakbar(
              'لا يمكن عرض تفاصيل هذا المنتج لانه غير موجود',
              type: SnackBarType.error,
            );
          }
        },
      ),
    );
  }
}
