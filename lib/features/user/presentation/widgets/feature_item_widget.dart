import 'package:flutter/material.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../domain/entities/status_config.dart';

class FeatureItemWidget extends StatelessWidget {
  const FeatureItemWidget({
    super.key,
    required this.text,
    required this.config,
  });

  final String text;
  final StatusConfig config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: config.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: config.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
