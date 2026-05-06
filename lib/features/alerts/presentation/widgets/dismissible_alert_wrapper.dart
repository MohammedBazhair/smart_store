import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../store/presentation/widgets/store_member_item.dart';
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
      background: const DismissibleBackground(isLeft: false),
      secondaryBackground: const DismissibleBackground(isLeft: true),
      onDismissed: (_) {
        ref.read(alertsControllerProvider.notifier).deleteAlert(alertId);
      },
      confirmDismiss: (_) => showDeleteAlertDialog(context),
      child: child,
    );
  }
}
