import '../../../core/utils/result.dart';

/// واجهة مستودع النسخ الاحتياطي
abstract class BackupRepository {
  /// إنشاء نسخة احتياطية
  Future<Result<String>> createBackup();

  /// استعادة النسخة الاحتياطية
  Future<Result<void>> restoreBackup(String backupPath);
}

