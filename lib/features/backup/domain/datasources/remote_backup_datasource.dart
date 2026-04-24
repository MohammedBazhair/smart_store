import '../../../../errors/result.dart';
import '../entities/backup_result.dart';

abstract class RemoteBackupDatasource {
  Future<Result<BackupResult>> backupDb(String tempFilePath);
  Future<Result<BackupResult>> restoreDb();
}
