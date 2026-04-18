import 'package:flutter/material.dart';

import '../../../../../core/shared/presentation/theme/app_theme.dart';

class ProductTitle extends StatelessWidget {
  const ProductTitle(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.fade,
      style: const TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 13,
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
