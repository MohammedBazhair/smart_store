import 'package:flutter/material.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';

Future<bool?> showConfirmationRestoreDialog(BuildContext context) {
  return showDialog<bool?>(
    context: context,
    builder: (context) => const ConfirmationRestoreDialog(),
  );
}

class ConfirmationRestoreDialog extends StatelessWidget {
  const ConfirmationRestoreDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تأكيد الاستعادة'),
      content: const Text(
        'سيتم استبدال جميع البيانات الحالية بالنسخة الاحتياطية. هل أنت متأكد؟',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        CustomButton(
          onPressed: () => Navigator.pop(context, true),
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          child: const Text('استعادة'),
        ),
      ],
    );
  }
}
