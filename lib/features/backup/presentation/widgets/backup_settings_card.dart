import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../errors/result.dart';
import '../controllers/backup_providers.dart';
import 'confirmation_restore_dialog.dart';
import 'create_backup_dialog.dart';
import 'current_backup_info.dart';
import 'restore_backup_dialog.dart';

class BackupSettingsCard extends ConsumerWidget {
  const BackupSettingsCard({
    super.key,
  });

  Future<void> _createBackup(WidgetRef ref, BuildContext context) async {
    final iscreateButtonClicked = await showCreateBackupDialog(context);

    if (!context.mounted || iscreateButtonClicked != true) return;

    final result =
        await ref.read(backupControllerProvider.notifier).createBackup();

    await _showMessage(context, result);
  }

  Future<void> _restoreBackup(WidgetRef ref, BuildContext context) async {
    final isRestoreButtonClicked = await showRestoreBackupDialog(context);
    if (isRestoreButtonClicked != true) return;

    final confirmed = await showConfirmationRestoreDialog(context);

    if (confirmed != true) return;

    final result =
        await ref.read(backupControllerProvider.notifier).restoreBackup();

    await _showMessage(context, result);
  }

  Future<void> _showMessage(BuildContext context, Result<String> result) async {
    switch (result) {
      case SuccessState<String>(:final data):
        context.showSnakbar(
          data,
          type: SnackBarType.success,
        );
      case ErrorState<String>(:final message):
        context.showSnakbar(message, type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    final isLoading = ref.read(backupControllerProvider.select((s)=>s.isLoading));

    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AbsorbPointer(
          absorbing: isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'النسخ الاحتياطي & الاستعادة',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 30),
              const CurrentBackupInfo(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _createBackup(ref, context),
                icon: const Icon(Icons.backup),
                label: const Text('إنشاء نسخة احتياطية'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                  elevation: 0,
                ),
                onPressed: () => _restoreBackup(ref, context),
                icon: const Icon(Icons.restore_rounded),
                label: const Text('استعادة نسخة احتياطية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
