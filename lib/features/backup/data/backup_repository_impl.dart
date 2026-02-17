import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../../../core/database/local/database_helper.dart';

import '../../../errors/result.dart';
import '../domain/backup_repository.dart';

/// تنفيذ مستودع النسخ الاحتياطي
class BackupRepositoryImpl implements BackupRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<Result<String>> createBackup() async {
    try {
      final dbPath = await _dbHelper.getDatabaseFilePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        return const ErrorState('قاعدة البيانات غير موجودة');
      }

      final directory = await getApplicationDocumentsDirectory();
      final year = DateTime.now().year;
      final backupFileName = 'app_backup_$year.db';
      final backupPath = '${directory.path}/$backupFileName';

      await dbFile.copy(backupPath);

      return SuccessState(backupFileName);
    } catch (e) {
      return ErrorState(
        'فشل في إنشاء النسخة الاحتياطية: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<void>> restoreBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        return const ErrorState('ملف النسخة الاحتياطية غير موجود');
      }

      final dbPath = await _dbHelper.getDatabaseFilePath();

      // إغلاق قاعدة البيانات الحالية
      await _dbHelper.close();

      // نسخ ملف النسخة الاحتياطية إلى موقع قاعدة البيانات
      await backupFile.copy(dbPath);

      // إعادة تهيئة قاعدة البيانات
      await _dbHelper.database;

      return const SuccessState(null);
    } catch (e) {
      return ErrorState(
        'فشل في استعادة النسخة الاحتياطية: ${e.toString()}',
      );
    }
  }
}
