import '../../../../errors/result.dart';
import '../entities/backup_result.dart';
import '../entities/backup_type.dart';

abstract class BackupRepository {
  Future<Result<BackupResult>> createBackup(BackupType backupType);

  Future<Result<BackupResult>> restoreBackup(RestoreBackupType source);
}

