import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/bottom_sheet_handle.dart';
import '../controllers/alert_provider.dart';

Future<void> showClearAlertsDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const ClearAlertsDialog(),
  );
}

class ClearAlertsDialog extends ConsumerWidget {
  const ClearAlertsDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),

          const SizedBox(height: 24),

          /// Premium Warning Circle
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.errorColor.withValues(alpha: 0.08),
              border: Border.all(
                color: AppTheme.errorColor.withValues(alpha: 0.15),
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.auto_delete_rounded,
              size: 42,
              color: AppTheme.errorColor,
            ),
          ),

          const SizedBox(height: 20),

          /// Title
          const Text(
            'حذف التنبيهات المقروءة',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'سيتم حذف جميع التنبيهات التي تمت قراءتها نهائيًا، ولن تتمكن من استعادتها لاحقًا.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 28),

          /// Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: context.pop,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(alertsControllerProvider.notifier)
                        .clearOldAlerts();

                    context.pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    elevation: 0,
                  ),
                  child: const Text(
                    'تأكيد الحذف',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
