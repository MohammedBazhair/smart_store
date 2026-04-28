import '../../../../errors/result.dart';
import '../../data/backup_file.helper.dart';
import '../entities/backup_result.dart';

abstract class LocalBackupDatasource {
  Future<Result<BackupResult>> backupDb(OnProgress onPregress);
  Future<Result<BackupResult>> restoreDb(OnProgress onProgress);
}
