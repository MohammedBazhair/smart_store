import '../../../../errors/result.dart';
import '../entities/backup_result.dart';

abstract class RemoteBackupDatasource {
  Future<Result<BackupResult>> backupDb([String? filePath]);
  Future<Result<BackupResult>> restoreDb();
}
