import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/providers/ui_providers.dart';
import '../../../../errors/result.dart';
import '../../../backup/presentation/backup_controller.dart';
import '../controllers/settings_provider.dart';

class BackupSettingsCard extends ConsumerWidget {
  const BackupSettingsCard({
    super.key,
  });

  Future<void> _createBackup(WidgetRef ref, BuildContext context) async {
    ref.read(isLoadingProvider(IsLoading.backup).notifier).update((i) => true);

    final controller = ref.read(backupControllerProvider.notifier);
    final result = await controller.createBackup();

    ref.read(isLoadingProvider(IsLoading.backup).notifier).update((i) => false);

    if (!context.mounted) return;

    if (result is SuccessState<String>) {
      context.showSnakbar(
        'تم إنشاء النسخة الاحتياطية: \n${result.data}',
        type: SnackBarType.success,
      );
    } else if (result is ErrorState<String>) {
      context.showSnakbar(result.message, type: SnackBarType.error);
    }
  }

  Future<void> _restoreBackup(WidgetRef ref, BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final backupPath = result.files.single.path!;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد الاستعادة'),
          content: const Text(
            'سيتم استبدال جميع البيانات الحالية بالنسخة الاحتياطية. هل أنت متأكد؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('استعادة'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        ref
            .read(isLoadingProvider(IsLoading.backup).notifier)
            .update((i) => true);

        final controller = ref.read(backupControllerProvider.notifier);
        final restoreResult = await controller.restoreBackup(backupPath);

        ref
            .read(isLoadingProvider(IsLoading.backup).notifier)
            .update((i) => false);

        if (!context.mounted) return;

        if (restoreResult is SuccessState<void>) {
          context.showSnakbar(
            'تم استعادة النسخة الاحتياطية',
            type: SnackBarType.success,
          );
          // إعادة تحميل البيانات
          ref.invalidate(settingsControllerProvider);
        } else if (restoreResult is ErrorState<void>) {
          context.showSnakbar(restoreResult.message, type: SnackBarType.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    final isLoading = ref.read(isLoadingProvider(IsLoading.backup));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'النسخ الاحتياطي',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            AbsorbPointer(
              absorbing: isLoading,
              child: ElevatedButton.icon(
                onPressed: () => _createBackup(ref, context),
                icon: const Icon(Icons.backup),
                label: const Text('إنشاء نسخة احتياطية'),
              ),
            ),
            const SizedBox(height: 12),
            AbsorbPointer(
              absorbing: isLoading,
              child: ElevatedButton.icon(
                onPressed: () => _restoreBackup(ref, context),
                icon: const Icon(Icons.model_training_rounded),
                label: const Text('استعادة نسخة احتياطية'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
