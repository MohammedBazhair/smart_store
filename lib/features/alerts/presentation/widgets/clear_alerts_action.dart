import 'package:flutter/material.dart';

import 'clear_alerts_dialog.dart';

class ClearReadAlertsAction extends StatelessWidget {
  const ClearReadAlertsAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'حذف كل التنبيهات المقروءة',
      icon: const Icon(Icons.delete_sweep_rounded),
      onPressed: () => showClearAlertsDialog(context),
    );
  }
}
