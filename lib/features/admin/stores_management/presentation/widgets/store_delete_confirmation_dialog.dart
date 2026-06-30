import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/widgets/dialogs/delete_confirmation_dialog.dart';

Future<bool> showDeleteStoreDialog(BuildContext context) async {
  final confirmDelete = await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DeleteConfirmationDialog(
      title: 'تأكيد حذف المتجر',
      description:
          'هل أنت متأكد من أنك تريد حذف هذا المتجر؟ لا يمكنك التراجع عن هذه العملية',
      cancelButtonText: 'إلغاء',
      confirmButtonText: 'حذف',
      onConfirmPressed: () => context.pop(true),
    ),
  );

  return confirmDelete?? false;
}
