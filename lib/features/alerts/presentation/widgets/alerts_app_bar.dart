import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/alert_provider.dart';

class AlertsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AlertsAppBar({super.key,});


  @override
  Widget build(BuildContext context,ref) {
    return AppBar(
      title: const Text('التنبيهات'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.invalidate(alertsProvider);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
