import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';

import '../../../../core/shared/presentation/widgets/common/bottom_sheet_handle.dart';

import '../../../auth/presentation/widgets/custom_button.dart';

Future<bool?> showConfirmationRestoreDialog(BuildContext context) {
  return showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const ConfirmationRestoreDialog(),
  );
}

class ConfirmationRestoreDialog extends ConsumerWidget {
  const ConfirmationRestoreDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [

          const BottomSheetHandle(),

          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor.withAlpha(30),
            foregroundColor: AppTheme.primaryColor,
            child: const Icon(
              Icons.cloud_download,
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'تأكيد الاستعادة',
            textAlign: TextAlign.center,
            style: TextTheme.of(context).titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'سيؤدي هذا الإجراء إلى استبدال بيانات المتجر الحالية بالنسخة الموجودة في النسخة الاحتياطية المحددة.\n لا يمكن التراجع عن هذا الإجراء بمجرد بدئه.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            onPressed: () => context.pop(true),
            child: const Text('استعادة الآن'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}
