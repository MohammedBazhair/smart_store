import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/info_row.dart';
import '../controllers/backup_providers.dart';

class CurrentBackupInfo extends ConsumerWidget {
  const CurrentBackupInfo({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(backupControllerProvider).backupState;
    if (state == null) return const EmptyBackupInfo();

    return Column(
      children: [
        InfoRow(
          icon: Icons.date_range,
          title: 'التاريخ',
          value: state.updatedAt.formattedDate(),
        ),
        const Divider(),
        InfoRow(
          icon: state.type.icon,
          title: 'نوع النسخة الاحتياطية',
          value: state.type.uiInfoBackup.title,
        ),
        const Divider(),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
            radius: 40,
            child: Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد نسخة احتياطية بعد',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'قم بإنشاء نسخة احتياطية لحماية بياناتك واستعادتها وقت الحاجة',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
