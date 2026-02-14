import 'package:flutter/material.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../domain/entities/status_config.dart';
import 'feature_item_widget.dart';

class StatusCardWidget extends StatelessWidget {
  const StatusCardWidget({super.key, required this.config});

  final StatusConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: config.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  config.primaryColor.withOpacity(0.2),
                  config.secondaryColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: config.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  config.icon,
                  size: 20,
                  color: config.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: config.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Status Description
          Text(
            config.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Status Features
          ...config.features.map(
            (feature) => FeatureItemWidget(text: feature, config: config),
          ),
        ],
      ),
    );
  }
}
