import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/log.dart';
import '../../../../core/database/local/database_helper.dart';
import '../../../../core/database/remote/remote_storage_service.dart';
import '../../../../core/network/network_clinet.dart';
import '../../../../errors/exceptions.dart';
import '../../../../errors/result.dart';
import '../../domain/datasources/remote_backup_datasource.dart';
import '../../domain/entities/backup_result.dart';
import '../../domain/entities/backup_state.dart';
import '../../domain/entities/backup_type.dart';
import '../backup_file.helper.dart';

class RemoteBackupDatasourceImpl extends RemoteBackupDatasource {
  RemoteBackupDatasourceImpl(
    this._remoteStorage,
    this.userId,
    this._networkClient,
    this._dbHelper,
  );

  final RemoteStorageService _remoteStorage;
  final DatabaseHelper _dbHelper;
  final NetworkClient _networkClient;
  final String userId;

  final _storageBucket = 'backups';
  final _backupName = 'DB Backup.s';
  String get _backupPathInBucket => '$userId/$_backupName';

  Future<String> _createTempFile() async {
    final dbFileBytes = await BackupFileHelper.readOriginalDbBytes();

    if (dbFileBytes == null) throw Exception();

    final readyFileBytes = BackupFileHelper.addBackupHeader(dbFileBytes);

    final dir = await getTemporaryDirectory();

    final dbFilePath = p.join(dir.path, _backupName);

    final file = File(dbFilePath);
    await file.writeAsBytes(readyFileBytes, flush: true);
    return dbFilePath;
  }

  @override
  Future<Result<BackupResult>> backupDb([String? filePath]) async {
    try {
      final dbFilePath = filePath ?? await _createTempFile();

      await _remoteStorage.uploadFile(
        fileName: _backupName,
        filePath: dbFilePath,
        storageBucket: _storageBucket,
        userId: userId,
      );

      final backupState = BackupState.fromFile(
        file: File(dbFilePath),
        type: BackupType.cloud,
      );
      final backupResult = BackupResult(
        state: backupState,
        dbFilePath: dbFilePath,
        message: 'تم انشاء النسخة الاحتياطية ورفعها للسحابة بنجاح',
      );

      return SuccessState(backupResult);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState('فشل في رفع النسخة الاحتياطية إلى السحابة');
    }
  }

  Future<Uint8List> _downloadFileBytes() async {
    try {
      final fileUrl = _remoteStorage.getUrlFrom(
        path: _backupPathInBucket,
        storageBucket: _storageBucket,
      );

      final fileBytes = await _networkClient.downloadFile(fileUrl);
      return fileBytes;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);

      throw const DownloadFileException(
        'فشل في تحميل النسخة الاحتياطية من السحابة',
      );
    }
  }

  @override
  Future<Result<BackupResult>> restoreDb() async {
    try {
      final rawBytes = await _downloadFileBytes();
      final fileBytes = BackupFileHelper.removeBackupHeader(rawBytes);

      final dbFilePath = await _dbHelper.getDatabaseFilePath();
      await _dbHelper.close();

      final target = File(dbFilePath);

      await target.writeAsBytes(fileBytes, flush: true);

      final backupState =
          BackupState.fromBytes(bytes: fileBytes, type: BackupType.cloud);
      final backupResult = BackupResult(
        state: backupState,
        dbFilePath: dbFilePath,
        message: 'تم استعادة النسخة الاحتياطية من السحابة',
      );

      return SuccessState(backupResult);
    } on AppException catch (e) {
      return ErrorState(e.message);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState('فشل في استعادة النسخة الاحتياطية من السحابة');
    }
  }
}
