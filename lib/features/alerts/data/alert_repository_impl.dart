import '../../../core/constants/log.dart';
import '../../../core/database/local/database_helper.dart';
import '../../../errors/result.dart';
import '../domain/alert.dart';
import '../domain/alert_repository.dart';
import 'alert_model.dart';

/// تنفيذ مستودع التنبيهات
class AlertRepositoryImpl implements AlertRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<Map<int, Alert>> getAllAlerts() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'alerts',
        orderBy: 'created_at DESC',
      );
      final entries = maps.map((m) {
        final alert = AlertModel.fromMap(m);
        return MapEntry(alert.id!, alert);
      });

      return Map.fromEntries(entries);
    } catch (e,st) {
      Logger.debugLog(error: e,stackTrace: st);
      return {};
    }
  }

  @override
  Future<Map<int, Alert>> getUnreadAlerts() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'alerts',
        where: 'is_read = ?',
        whereArgs: [0],
        orderBy: 'created_at DESC',
      );
      final entries = maps.map((m) {
        final alert = AlertModel.fromMap(m);
        return MapEntry(alert.id!, alert);
      });

      return Map.fromEntries(entries);
    } catch (e,st) {
      Logger.debugLog(error: e,stackTrace: st);
      return {};
    }
  }

  @override
  Future<Map<int, Alert>> getNewAlerts() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'alerts',
        orderBy: 'created_at DESC',
        limit: 3,
      );
      final entries = maps.map((m) {
        final alert = AlertModel.fromMap(m);
        return MapEntry(alert.id!, alert);
      });

      return Map.fromEntries(entries);
    } catch (e,st) {
      Logger.debugLog(error: e,stackTrace: st);
      return {};
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
    } catch (e,st) {
      Logger.debugLog(error: e,stackTrace: st);
      return ErrorState('فشل في تحديث التنبيه: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAlertDuplicated({
    required String productId,
    required DateTime expiryDate,
    required int daysBeforeExpiry,
  }) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'alerts',
      where: 'product_id = ? AND DATE(expiry_date) = DATE(?) AND days_before_expiry = ?',
      whereArgs: [productId, expiryDate.toIso8601String(), daysBeforeExpiry],
    );

    return result.isNotEmpty; // true إذا موجود مسبقًا
  }

  @override
  Future<Result<void>> deleteAlert(int id) async {
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
