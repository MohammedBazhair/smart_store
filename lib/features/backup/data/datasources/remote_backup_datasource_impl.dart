import 'dart:io';
import 'dart:typed_data';

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

class RemoteBackupDatasourceImpl extends RemoteBackupDatasource {
  RemoteBackupDatasourceImpl(
    this._remoteStorage,
    this.userPhone,
    this._networkClient,
    this._dbHelper,
  );

  final RemoteStorageService _remoteStorage;
  final DatabaseHelper _dbHelper;
  final NetworkClient _networkClient;
  final String userPhone;

  final _storageBucket = 'db_backups';
  final _backupName = 'DB Backup.db';
  String get _backupPathInBucket => '$userPhone/$_backupName';

  @override
  Future<Result<BackupResult>> backupDb(String tempFilePath) async {
    try {
      await _remoteStorage.uploadFile(
        fileName: _backupName,
        filePath: tempFilePath,
        storageBucket: _storageBucket,
        userPhone: userPhone,
      );

      final backupState = BackupState.from(
        file: File(tempFilePath),
        type: BackupType.cloud,
      );
      final backupResult = BackupResult(
        state: backupState,
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

  Future<String> _createTempFileFromBytes(Uint8List fileBytes) async {
    final dir = await getTemporaryDirectory();
    final tempFilePath = '${dir.path}/$_backupName';

    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(fileBytes);
    return tempFilePath;
  }

  @override
  Future<Result<BackupResult>> restoreDb() async {
    try {
      final fileBytes = await _downloadFileBytes();
      final tempFilePath = await _createTempFileFromBytes(fileBytes);

      final dbFilePath = await _dbHelper.getDatabaseFilePath();
      await _dbHelper.close();

      final tempFile = File(tempFilePath);
      final target = File(dbFilePath);

      if (await target.exists()) await target.delete();

      await tempFile.copy(dbFilePath);

      final backupState =
          BackupState.from(file: tempFile, type: BackupType.cloud);
      final backupResult = BackupResult(
        state: backupState,
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
