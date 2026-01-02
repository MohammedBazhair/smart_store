import '../../../core/data/database_helper.dart';
import '../../../core/utils/result.dart';
import '../domain/settings.dart';
import '../domain/settings_repository.dart';
import 'settings_model.dart';

/// تنفيذ مستودع الإعدادات
class SettingsRepositoryImpl implements SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<Result<Settings>> getSettings() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('settings', limit: 1);
      if (maps.isEmpty) {
        return const ErrorState('الإعدادات غير موجودة');
      }
      final settings = SettingsModel.fromMap(maps.first);
      return SuccessState(settings);
    } catch (e) {
      return ErrorState('فشل في جلب الإعدادات: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> updateSettings(Settings settings) async {
    try {
      final db = await _dbHelper.database;
      final model = SettingsModel.fromEntity(settings);

      await db.update(
        'settings',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [settings.id],
      );

      return const SuccessState(null);
    } catch (e) {
      return ErrorState('فشل في تحديث الإعدادات: ${e.toString()}');
    }
  }
}
