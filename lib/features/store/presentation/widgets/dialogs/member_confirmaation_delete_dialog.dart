import 'package:flutter/material.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/widgets/dialogs/delete_confirmation_dialog.dart';

Future<bool?> showDeleteMemberConfirmDialog(
  BuildContext context,
) {
  return showDialog<bool?>(
    context: context,
    builder: (_) {
      return const MemberConfirmaationDeleteDialog();
    },
  );
}

class MemberConfirmaationDeleteDialog extends StatelessWidget {
  const MemberConfirmaationDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DeleteConfirmationDialog(
      title: 'تأكيد حذف العضو',
      description: 'هل أنت متأكد أنك ترغب بإزالة هذا العضو من متجرك؟',
      descriptionAlign: TextAlign.center,
      cancelButtonText: 'تراجع',
      confirmButtonText: 'إزالة العضو',
      onCancelPressed: () => context.pop(false),
      onConfirmPressed: () => context.pop(true),
    );
  }
}
