import '../../../core/data/database_helper.dart';
import '../../../core/utils/result.dart';
import '../domain/alert.dart';
import '../domain/alert_repository.dart';
import 'alert_model.dart';

/// تنفيذ مستودع التنبيهات
class AlertRepositoryImpl implements AlertRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<Result<List<Alert>>> getAllAlerts() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'alerts',
        orderBy: 'created_at DESC',
      );
      final alerts = maps.map(AlertModel.fromMap).toList();
      return SuccessState(alerts);
    } catch (e) {
      return ErrorState('فشل في جلب التنبيهات: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Alert>>> getUnreadAlerts() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'alerts',
        where: 'is_read = ?',
        whereArgs: [0],
        orderBy: 'created_at DESC',
      );
      final alerts = maps.map(AlertModel.fromMap).toList();
      return SuccessState(alerts);
    } catch (e) {
      return ErrorState(
        'فشل في جلب التنبيهات غير المقروءة: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<int>> addAlert(Alert alert) async {
    try {
      final db = await _dbHelper.database;
      final model = AlertModel.fromEntity(alert);
      final id = await db.insert('alerts', model.toMap());
      return SuccessState(id);
    } catch (e) {
      return const ErrorState('فشل في إضافة التنبيه');
    }
  }

  @override
  Future<Result<void>> markAlertAsRead(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'alerts',
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const SuccessState(null);
    } catch (e) {
      return ErrorState('فشل في تحديث التنبيه: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteAlert(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'alerts',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const SuccessState(null);
    } catch (e) {
      return ErrorState('فشل في حذف التنبيه: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteAllAlerts() async {
    try {
      final db = await _dbHelper.database;
      await db.delete('alerts');
      return const SuccessState(null);
    } catch (e) {
      return ErrorState(
        'فشل في حذف جميع التنبيهات: ${e.toString()}',
      );
    }
  }
}
