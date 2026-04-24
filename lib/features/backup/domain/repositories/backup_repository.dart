import '../../../../errors/result.dart';
import '../entities/backup_result.dart';
import '../entities/backup_state.dart';

abstract class BackupRepository {
  Future<Result<BackupResult>> createBackup(BackupType backupType);

  Future<Result<BackupResult>> restoreBackup(BackupType source);
}

