import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../domain/entities/alert.dart';
import '../controllers/alert_provider.dart';

class AlertCard extends ConsumerWidget {
  const AlertCard({super.key, required this.alert});

  final Alert alert;

  Color getColorBackground() {
    return switch (alert.expiryRemainder.daysBeforeExpiry) {
      <= 27 => AppTheme.expiredColor,
      _ => AppTheme.nearExpiryColor,
    };
  }

  Icon getIcon() {
    final iconData = switch (alert.expiryRemainder.daysBeforeExpiry) {
      <= 27 => Icons.cancel_rounded,
      _ => Icons.warning_rounded,
    };

    return Icon(iconData, size: 24);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: alert.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: getColorBackground(),
          child: getIcon(),
        ),
        title: Text(
          alert.productName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
              ),
        ),
        subtitle: Text(
          '${alert.expiryRemainder.daysBeforeExpiry} أيام قبل الانتهاء',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: !alert.isRead
            ? SvgPicture.asset(
                'assets/icons/fire-alarm-icon.svg',
                color: getColorBackground(),
                width: 18,
              )
            : null,
        onTap: () {
          ref.read(alertControllerProvider.notifier).markAsRead(alert.id!);

          ref.read(currentProductIdProvider.notifier).state = alert.productId;
          context.pushTo(const ProductDetailsScreen());
        },
      ),
    );
  }
}
