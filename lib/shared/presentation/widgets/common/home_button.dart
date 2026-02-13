import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../features/dashboard/presentation/screen/dashboard_screen.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 30,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: () {
        context.pushTo(const DashboardScreen());
      },
      icon: const Icon(Icons.home),
    );
  }
}
