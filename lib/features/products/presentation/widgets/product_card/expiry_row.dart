import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../../shared/presentation/theme/app_theme.dart';
import '../../../domain/product_expiry_status.dart';

class ExpiryRow extends StatelessWidget {
  const ExpiryRow(this.date, this.status, {super.key});

  final DateTime date;
  final ProductExpiryStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today,
          size: 14,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          date_utils.DateUtils.formatDate(date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Skeleton.leaf(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
