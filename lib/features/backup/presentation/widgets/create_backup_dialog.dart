import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../domain/entities/backup_state.dart';
import '../controllers/backup_providers.dart';

Future<bool?> showCreateBackupDialog(BuildContext context) {
  return showModalBottomSheet<bool?>(
    context: context,
    builder: (context) => const CreateBackupDialog(),
  );
}

class CreateBackupDialog extends ConsumerWidget {
  const CreateBackupDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Column(
      spacing: 12,
      children: [
        const Text('اختر نوع النسخة الاحتياطية'),
        const Text('حدد المكان الذي تود حفظ النسخة الاحتياطية فيه'),
        const BackupTypeSelection(),
        CustomButton(
          onPressed: ()  {
            

            context.pop<bool>(true);
          },
          child: const Text('إنشاء نسخة احتياطية'),
        ),
      ],
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
      child: Column(
        children: BackupType.values.map(
          (type) {
            final isSelected = selectedType == type;
            return RadioListTile(
              value: type,
              title: Text(type.label),
              secondary: Icon(isSelected ? Icons.check_circle : type.icon),
              fillColor: isSelected
                  ? WidgetStateProperty.all(
                      AppTheme.primaryColor.withOpacity(0.2),
                    )
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
