import 'dart:typed_data';

import '../../../../errors/result.dart';
import '../entities/backup_result.dart';

abstract class LocalBackupDatasource {
  /// Return Result File path as SuccessState(String)
  Future<Result<BackupResult>> backupDb();
  Future<Uint8List?> readOriginalDbBytes();
  Future<Result<BackupResult>> restoreDb();
}
