import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../controllers/backup_providers.dart';
import '../controllers/backup_ui_state.dart';
import '../dialogs/create_backup_dialog.dart';
import '../dialogs/restore_backup_dialog.dart';
import '../screens/backup_loading_screen.dart';
import '../screens/backup_success_screen.dart';
import '../screens/restore_loading_screen.dart';
import 'current_backup_info.dart';

class BackupSettingsCard extends ConsumerWidget {
  const BackupSettingsCard({
    super.key,
  });

  void goLoadingScreen(BuildContext context, BackupOperationType? operation) {
    if (operation == null) return;

    final screen = switch (operation) {
      BackupOperationType.backup => const BackupLoadingScreen(),
      BackupOperationType.restore => const RestoreLoadingScreen(),
    };

    context.pushTo(screen);
  }

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(
      backupControllerProvider,
      (_, state) {
        if (state.isLoading) goLoadingScreen(context, state.currentOperation);

        if (!state.hasMessage) return;

        context.showSnakbar(state.message!, type: state.messageType!);
        
        if (state.messageType == SnackBarType.success) {
          context.pushReplacementTo(const BackupSuccessScreen());
        } else {
          context.pop();
        }
      },
    );

    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              onPressed: () => showCreateBackupDialog(context, ref),
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
              onPressed: () => showRestoreBackupDialog(context, ref),
              icon: const Icon(Icons.restore_rounded),
              label: const Text('استعادة نسخة احتياطية'),
            ),
          ],
        ),
      ),
    );
  }
}
