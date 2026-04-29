import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../controllers/alert_provider.dart';
import 'delete_alert_dialog.dart';

class DismissibleAlertWrapper extends ConsumerWidget {
  const DismissibleAlertWrapper({
    super.key,
    required this.child,
    required this.alertId,
  });

  final Widget child;
  final int alertId;

  @override
  Widget build(BuildContext context, ref) {
    return Dismissible(
      key: ValueKey(alertId),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      onDismissed: (_) {
        ref.read(alertsControllerProvider.notifier).deleteAlert(alertId);
      },
      confirmDismiss: (_) => showDeleteAlertDialog(context),
      child: child,
    );
  }
}
