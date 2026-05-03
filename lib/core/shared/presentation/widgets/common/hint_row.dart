import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class HintRow extends StatelessWidget {
  const HintRow({
    super.key,
    required this.message,
    required this.iconData,
  });

  final String message;
  final IconData iconData;

  /// Ensures the message ends with a period.
  String get _formattedMessage => message.endsWith('.') ? message : '$message.';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          iconData,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formattedMessage,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                height: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
