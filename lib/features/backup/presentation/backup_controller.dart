import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../errors/result.dart';
import '../../../shared/providers/repositories_provider.dart';

/// Controller لإدارة النسخ الاحتياطي
class BackupController extends Notifier<void> {
  @override
  void build() {}

  /// إنشاء نسخة احتياطية
  Future<Result<String>> createBackup() {
    final repository = ref.read(backupRepositoryProvider);
    return  repository.createBackup();
  }

  /// استعادة النسخة الاحتياطية
  Future<Result<void>> restoreBackup(String backupPath) {
    final repository = ref.read(backupRepositoryProvider);
    return repository.restoreBackup(backupPath);
  }
}

/// Provider للـ BackupController
final backupControllerProvider = NotifierProvider<BackupController, void>(() {
  return BackupController();
});
