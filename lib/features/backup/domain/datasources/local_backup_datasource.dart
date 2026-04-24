import '../../../../errors/result.dart';
import '../entities/backup_result.dart';

abstract class LocalBackupDatasource {
  /// Return Result File path as SuccessState(String)
  Future<Result<BackupResult>> backupDb();
  Future<String?> createTempBackupDb();
  Future<Result<BackupResult>> restoreDb();
}
