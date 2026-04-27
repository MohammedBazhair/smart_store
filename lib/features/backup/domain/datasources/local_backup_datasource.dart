import '../../../../errors/result.dart';
import '../entities/backup_result.dart';

abstract class LocalBackupDatasource {
  Future<Result<BackupResult>> backupDb();
  Future<Result<BackupResult>> restoreDb();
}
