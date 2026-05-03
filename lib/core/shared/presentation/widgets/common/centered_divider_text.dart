import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class CenteredDividerText extends StatelessWidget {
  const CenteredDividerText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
