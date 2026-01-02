import 'package:flutter/material.dart';

import '../../../../../shared/presentation/theme/app_theme.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton(this.onPressed, {super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      color: AppTheme.errorColor,
      onPressed: onPressed,
    );
  }
}
