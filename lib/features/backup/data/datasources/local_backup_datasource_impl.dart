import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/database_helper.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../errors/result.dart';
import '../../domain/datasources/local_backup_datasource.dart';
import '../../domain/entities/backup_result.dart';
import '../../domain/entities/backup_state.dart';
import '../../domain/entities/backup_type.dart';

class LocalBackupDatasourceImpl extends LocalBackupDatasource {
  LocalBackupDatasourceImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;

  String get _backupName {
    final date = DateTime.now().formattedDate('-');
    return 'نسخة احتياطية للمتجر الذكي بتاريخ ($date).db';
  }

  @override
  Future<Result<BackupResult>> backupDb() async {
    try {
      final dbFileBytes = await readOriginalDbBytes();
      if (dbFileBytes == null) {
        return const ErrorState(
          'حصلت مشكلة اثناء قراءة نسخة من بيانات المحلية',
        );
      }

      final outPath = await FilePicker.platform.saveFile(
        allowedExtensions: ['db'],
        bytes: dbFileBytes,
        type: FileType.custom,
        fileName: _backupName,
      );

      if (outPath == null) return const ErrorState('يجب اختيار مسار للحفظ');

      final backupState =
          BackupState.fromBytes(bytes: dbFileBytes, type: BackupType.local);

      final backupResult = BackupResult(
        state: backupState,
        message: 'تم انشاء النسخة الاحتياطية وحفظها محليا',
      );

      return SuccessState(backupResult);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState(
        'فشل في إنشاء النسخة الاحتياطية المحلية',
      );
    }
  }

  @override
  Future<Uint8List?> readOriginalDbBytes() async {
    try {
      await _dbHelper.close();
      final dbPath = await _dbHelper.getDatabaseFilePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) return null;

      return await dbFile.readAsBytes();
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<Result<BackupResult>> restoreDb() async {
    try {
      final result = await FilePicker.platform
          .pickFiles(allowedExtensions: ['db'], type: FileType.custom);

      final backupFilePath = result?.paths.firstOrNull;
      if (backupFilePath == null) {
        return const ErrorState(
          'لم يتم اختيار ملف النسخة الاحتياطية',
        );
      }

      final backupFile = File(backupFilePath);
      final backupBytes = await backupFile.readAsBytes();
      final dbFilePath = await _dbHelper.getDatabaseFilePath();
      final target = File(dbFilePath);

      await _dbHelper.close();

      await target.writeAsBytes(backupBytes);

      final backupState =
          BackupState.fromBytes(bytes: backupBytes, type: BackupType.local);
      final backupResult = BackupResult(
        state: backupState,
        message: 'تم استعادة النسخة الاحتياطية محليا',
      );

      return SuccessState(backupResult);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return const ErrorState(
        'فشل في استعادة النسخة الاحتياطية من ملفك',
      );
    }
  }
}
