import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../domain/entities/backup_state.dart';
import '../controllers/backup_providers.dart';

Future<bool?> showRestoreBackupDialog(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    builder: (context) => const RestoreBackupDialog(),
  );
}

class RestoreBackupDialog extends ConsumerWidget {
  const RestoreBackupDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Column(
      spacing: 12,
      children: [
        const Text('اختر مصدر الاستعادة'),
        const Text('حدد المكان الذي تود استعادة منه بياناتك المخزنة'),
        const RestoreSourceSelection(),
        CustomButton(
          onPressed: () => context.pop<bool>(true),
          child: const Text('استعادة نسخة'),
        ),
      ],
    );
  }
}

class RestoreSourceSelection extends ConsumerWidget {
  const RestoreSourceSelection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final selectedType = ref.watch(restoreSourceProvider);
    return RadioGroup<BackupType>(
      groupValue: selectedType,
      onChanged: (value) {
        if (value == null) return;
        ref.read(backupTypeProvider.notifier).state = value;
      },
      child: Column(
        children: BackupType.values.where((t) => t != BackupType.hybrid).map(
          (type) {
            final isSelected = selectedType == type;
            return RadioListTile(
              value: type,
              title: Text(type.label),
              secondary: CircleAvatar(
                radius: 20,
                child: Icon(type.icon),
              ),
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
