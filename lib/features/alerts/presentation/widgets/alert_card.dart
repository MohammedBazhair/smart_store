import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../domain/entities/alert.dart';
import '../controllers/alert_provider.dart';

class AlertCard extends ConsumerWidget {
  const AlertCard({super.key, required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importanceColor = alert.priority == Priority.high
        ? AppTheme.errorColor
        : alert.priority == Priority.defaultPriority
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
        subtitle: Text(
          '${alert.remainingDays} أيام قبل الانتهاء',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Icon(
          alert.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
          color: AppTheme.primaryColor,
        ),
        onTap: () {
          ref.read(alertControllerProvider.notifier).markAsRead(alert.id!);

          ref.read(currentProductIdProvider.notifier).state = alert.productId;
          context.pushTo(const ProductDetailsScreen());
        },
      ),
    );
  }
}
