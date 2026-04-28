import '../../../../errors/result.dart';
import '../../data/backup_file.helper.dart';
import '../entities/backup_result.dart';
import '../entities/backup_type.dart';

abstract class BackupRepository {
  Future<Result<BackupResult>> createBackup(BackupType backupType, OnProgress onPregress);

  Future<Result<BackupResult>> restoreBackup(RestoreBackupType source, OnProgress onPregress);
}

