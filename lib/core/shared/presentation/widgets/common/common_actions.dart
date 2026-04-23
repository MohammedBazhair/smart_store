import 'package:flutter/material.dart';

import '../../../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../../extensions/extensions.dart';

class SettingsActonIcon extends StatelessWidget {
  const SettingsActonIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'الإعدادات',
      icon: const Icon(Icons.settings),
      onPressed: () {
        context.pushTo(const SettingsScreen());
      },
    );
  }
}
