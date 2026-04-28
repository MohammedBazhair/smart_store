import '../../../../errors/result.dart';
import '../../data/backup_file.helper.dart';
import '../entities/backup_result.dart';

abstract class RemoteBackupDatasource {
  Future<Result<BackupResult>> backupDb([String? filePath, OnProgress? onProgress]);
  Future<Result<BackupResult>> restoreDb(OnProgress onProgress);
}
