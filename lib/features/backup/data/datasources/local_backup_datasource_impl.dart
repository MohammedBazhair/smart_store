import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/database_helper.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../errors/result.dart';
import '../../domain/datasources/local_backup_datasource.dart';
import '../../domain/entities/backup_result.dart';
import '../../domain/entities/backup_state.dart';
import '../../domain/entities/backup_type.dart';
import '../backup_file.helper.dart';

class LocalBackupDatasourceImpl extends LocalBackupDatasource {
  LocalBackupDatasourceImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;

  String get _backupName {
    final date = DateTime.now().formattedDate('-');
    return 'نسخة احتياطية للمتجر الذكي بتاريخ ($date).s';
  }

  @override
  Future<Result<BackupResult>> backupDb() async {
    try {
      final dbFileBytes = await BackupFileHelper.readOriginalDbBytes();
      if (dbFileBytes == null) {
        return const ErrorState(
          'حصلت مشكلة اثناء قراءة نسخة من بيانات المحلية',
        );
      }
      final encryptedDbBytes = BackupFileHelper.addBackupHeader(dbFileBytes);
      final outPath = await FilePicker.platform.saveFile(
        bytes: encryptedDbBytes,
        fileName: _backupName,
      );

      if (outPath == null) return const ErrorState('يجب اختيار مسار للحفظ');

      final backupState = BackupState.fromBytes(
        bytes: encryptedDbBytes,
        type: BackupType.local,
      );

      final backupResult = BackupResult(
        state: backupState,
        message: 'تم إنشاء النسخة الاحتياطية المحلية بنجاح',
        dbFilePath: outPath,
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
  Future<Result<BackupResult>> restoreDb() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      final backupFilePath = result?.paths.firstOrNull;
      if (backupFilePath == null) {
        return const ErrorState(
          'لم يتم اختيار ملف النسخة الاحتياطية',
        );
      }

      final extension = p.extension(backupFilePath);

      if (extension != '.s') {
        return const ErrorState('يجب اختيار ملف بامتداد مناسب');
      }

      final backupFile = File(backupFilePath);
      final encryptedBackupBytes = await backupFile.readAsBytes();
      final backupBytes =
          BackupFileHelper.removeBackupHeader(encryptedBackupBytes);
      final dbFilePath = await _dbHelper.getDatabaseFilePath();
      final target = File(dbFilePath);

      await _dbHelper.close();

      await target.writeAsBytes(backupBytes, flush: true);

      final backupState =
          BackupState.fromBytes(bytes: backupBytes, type: BackupType.local);
      final backupResult = BackupResult(
        state: backupState,
        dbFilePath: dbFilePath,
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
