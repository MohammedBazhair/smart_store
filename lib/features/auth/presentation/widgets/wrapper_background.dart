import 'package:flutter/material.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';

class WrapperBackground extends StatelessWidget {
  const WrapperBackground({
    super.key,
    required this.child,
    this.color,
  });
  final Color? color;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 20,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
