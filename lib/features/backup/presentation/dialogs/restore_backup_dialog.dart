import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../domain/entities/backup_type.dart';
import '../controllers/backup_providers.dart';
import 'confirmation_restore_dialog.dart';

Future<void> showRestoreBackupDialog(BuildContext context, WidgetRef ref) async {
  final isButtonClicked = await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const RestoreBackupDialog(),
  );

  if (isButtonClicked != true) return;

  final shouldRestore = await showConfirmationRestoreDialog(context);

  if (shouldRestore != true) return;
  
  await ref.read(backupControllerProvider.notifier).restoreBackup();

}

class RestoreBackupDialog extends ConsumerWidget {
  const RestoreBackupDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(
            'اختر مصدر الاستعادة',
            style: TextTheme.of(context).titleLarge,
          ),
          const Text(
            'حدد المكان الذي تود استعادة منه بياناتك المخزنة',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 12),
          const RestoreSourceSelection(),
          const SizedBox(height: 12),
          CustomButton(
            onPressed: () => context.pop(true),
            child: const Text('استعادة نسخة'),
          ),
        ],
      ),
    );
  }
}

class RestoreSourceSelection extends ConsumerWidget {
  const RestoreSourceSelection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final selectedType = ref.watch(restoreSourceProvider);

    return RadioGroup<RestoreBackupType>(
      groupValue: selectedType,
      onChanged: (value) {
        if (value == null) return;
        ref.read(restoreSourceProvider.notifier).state = value;
      },
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: RestoreBackupType.values.length,
        itemBuilder: (context, index) {
          final type = RestoreBackupType.values.elementAt(index);
          final isSelected = selectedType == type;
          final (:title, :subtitle) = type.uiInfoRestore;
          return RadioListTile(
            value: type,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                height: 2,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            secondary: CircleAvatar(
              backgroundColor: Colors.grey.withAlpha(20),
              radius: 24,
              child: Icon(
                type.icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                width: isSelected ? 2 : 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
