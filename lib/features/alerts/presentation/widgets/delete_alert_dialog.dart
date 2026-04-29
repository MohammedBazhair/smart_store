import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/bottom_sheet_handle.dart';

Future<bool?> showDeleteAlertDialog(BuildContext context) {
  return showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const DeleteAlertDialog(),
  );
}

class DeleteAlertDialog extends ConsumerWidget {
  const DeleteAlertDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.all(24),      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
      
          const SizedBox(height: 24),
      
          /// Delete Icon Circle
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
              Icons.delete_outline_rounded,
              size: 40,
              color: AppTheme.errorColor,
            ),
          ),
      
          const SizedBox(height: 20),
      
          /// Title
          const Text(
            'حذف التنبيه',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
      
          const SizedBox(height: 10),
      
          /// Description
          Text(
            'هل أنت متأكد من حذف هذا التنبيه؟\nلن تتمكن من استعادته بعد الحذف.',
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
                  onPressed:()=> context.pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    elevation: 0,
                  ),
                  child: const Text(
                    'تأكيد الحذف',
                    style: TextStyle(
                      fontSize: 15,
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
