import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../domain/entities/backup_type.dart';
import '../controllers/backup_providers.dart';

Future<bool?> showCreateBackupDialog(BuildContext context) {
  return showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const CreateBackupDialog(),
  );
}

class CreateBackupDialog extends ConsumerWidget {
  const CreateBackupDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(
            'اختر نوع النسخة الاحتياطية',
            style: TextTheme.of(context).titleLarge,
          ),
          const Text('حدد المكان الذي تود حفظ النسخة الاحتياطية فيه'),
          const SizedBox(height: 12),
          const BackupTypeSelection(),
          const SizedBox(height: 12),
          CustomButton(
            onPressed: () {
              context.pop<bool>(true);
            },
            child: const Text('إنشاء نسخة احتياطية'),
          ),
        ],
      ),
    );
  }
}

class BackupTypeSelection extends ConsumerWidget {
  const BackupTypeSelection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final selectedType = ref.watch(backupTypeProvider);
    return RadioGroup<BackupType>(
      groupValue: selectedType,
      onChanged: (value) {
        if (value == null) return;
        ref.read(backupTypeProvider.notifier).state = value;
      },
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: BackupType.values.length,
        itemBuilder: (context, index) {
          final type = BackupType.values.elementAt(index);
          final (:title, :subtitle) = type.uiInfoBackup;
          final isSelected = selectedType == type;
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
            secondary: Icon(
              type.icon,
              color: AppTheme.primaryColor,
            ),
          
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
