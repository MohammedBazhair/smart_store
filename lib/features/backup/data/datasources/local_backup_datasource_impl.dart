import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

  @override
  Future<Result<BackupResult>> backupDb() async {
    try {
      final dbFilePath = await createTempBackupDb();
      if (dbFilePath == null) {
        return const ErrorState('حصلت مشكلة اثناء حفظ نسخة محلية');
      }

      final tempDbFile = File(dbFilePath);

      final outPath = await FilePicker.platform.getDirectoryPath();

      if (outPath == null) return const ErrorState('يجب اختيار مسار للحفظ');
      final fileName = p.basename(dbFilePath);
      final resultBackupFilePath = p.join(outPath,fileName);
      await tempDbFile.copy(resultBackupFilePath);

      final backupState =
          BackupState.from(file: tempDbFile, type: BackupType.local);

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

  String get _backupName {
    final date = DateTime.now().formattedDate('-');
    return 'نسخة احتياطية للمتجر الذكي بتاريخ ($date).db';
  }

  @override
  Future<String?> createTempBackupDb() async {
    try {
      await _dbHelper.close();
      final dbPath = await _dbHelper.getDatabaseFilePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) return null;

      final dir = await getTemporaryDirectory();
      final outPath = dir.path;

      final backupFilePath =p.join( outPath,_backupName);

      await dbFile.copy(backupFilePath);

      return backupFilePath;
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
      final dbFilePath = await _dbHelper.getDatabaseFilePath();
      final target = File(dbFilePath);

      await _dbHelper.close();

      if (await target.exists()) await target.delete();

      await backupFile.copy(dbFilePath);

      final backupState =
          BackupState.from(file: backupFile, type: BackupType.local);
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
