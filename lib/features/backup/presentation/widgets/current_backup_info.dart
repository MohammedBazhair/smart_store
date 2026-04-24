import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/widgets/common/info_row.dart';
import '../controllers/backup_providers.dart';

class CurrentBackupInfo extends ConsumerWidget {
  const CurrentBackupInfo({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(backupControllerProvider);
    if (state == null) return const EmptyBackupInfo();
    
    return Column(
      children: [
        InfoRow(
          icon: Icons.date_range,
          title: 'اخر تحديث',
          value: state.updatedAt.formattedDate(),
        ),
        InfoRow(
          icon: state.type.icon,
          title: 'نوع النسخة الاحتياطية',
          value: state.type.label,
        ),
        InfoRow(
          icon: Icons.storage,
          title: 'حجم النسخة',
          value: state.sizeText,
        ),
      ],
    );
  }
}

class EmptyBackupInfo extends StatelessWidget {
  const EmptyBackupInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد نسخة احتياطية بعد',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'قم بإنشاء نسخة احتياطية لحماية بياناتك واستعادتها وقت الحاجة',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
