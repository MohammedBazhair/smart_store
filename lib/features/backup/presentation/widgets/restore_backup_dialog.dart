import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../domain/entities/backup_type.dart';
import '../controllers/backup_providers.dart';

Future<bool?> showRestoreBackupDialog(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const RestoreBackupDialog(),
  );
}

class RestoreBackupDialog extends ConsumerWidget {
  const RestoreBackupDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
            title: Text(title,
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
              radius: 20,
              child: Icon(
                type.icon,
                color: AppTheme.primaryColor,
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
