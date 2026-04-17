import '../../../../core/constants/log.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/database/local/query_where_builder.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../models/alert_model.dart';

/// تنفيذ مستودع التنبيهات
class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl(this._db);

  final LocalDatabaseService _db;

  @override
  Future<Map<int, Alert>> getAllAlerts() async {
    try {
      final maps =
          await _db.query(table: 'alerts', orderBy: 'days_before_expiry');

      final result = <int, AlertModel>{};

      for (final m in maps) {
        final alert = AlertModel.fromMap(m);
        result[alert.id!] = alert;
      }

      return result;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return {};
    }
  }

  @override
  Future<Map<int, Alert>> getUnreadAlerts() async {
    try {
      final maps = await _db.query(
        table: 'alerts',
        whereParams: const WhereQueryParams(
          groups: [
            FilterGroup(filters: [Filter(column: 'is_read', value: 0)]),
          ],
        ),
        orderBy: 'created_at DESC',
      );

      final result = <int, AlertModel>{};

      for (final m in maps) {
        final alert = AlertModel.fromMap(m);
        result[alert.id!] = alert;
      }

      return result;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return {};
    }
  }

  @override
  Future<Result<int>> addAlert(Alert alert) async {
    try {
      final model = AlertModel.fromEntity(alert);
      final id = await _db.insertRow(table: 'alerts', map: model.toMap());
      return SuccessState(id);
    } catch (e) {
      return const ErrorState('فشل في إضافة التنبيه');
    }
  }

  @override
  Future<Result<void>> markAlertAsRead(int id) async {
    try {
      await _db.update(
        updated: {'is_read': 1},
        whereParams: WhereQueryParams(
          groups: [
            FilterGroup(filters: [Filter(column: 'id', value: id)]),
          ],
        ),
        table: 'alerts',
      );

      return const SuccessState(null);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return ErrorState('فشل في تحديث التنبيه: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAlertDuplicated({
    required String productId,
    required DateTime expiryDate,
    required int daysBeforeExpiry,
  }) async {
    final result = await _db.query(
      table: 'alerts',
      whereParams: WhereQueryParams(
        groups: [
          FilterGroup(
            filters: [
              Filter(column: 'product_id', value: productId),
              Filter(
                column: 'expiry_date',
                value: expiryDate.toUtcDateOnly.toIso8601String(),
              ),
              Filter(column: 'days_before_expiry', value: daysBeforeExpiry),
            ],
          ),
        ],
      ),
    );

    return result.isNotEmpty; // true إذا موجود مسبقًا
  }

  @override
  Future<Result<void>> deleteAlert(int id) async {
    try {
      await _db.deleteWhere(
        table: 'alerts',
        whereParams: WhereQueryParams(
          groups: [
            FilterGroup(filters: [Filter(column: 'id', value: id)]),
          ],
        ),
      );
      return const SuccessState(null);
    } catch (e) {
      return ErrorState('فشل في حذف التنبيه: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOldAlerts() async {
    final date = DateTime.now().subtract(const Duration(days: 30)).toUtcDateOnly;

    final params = WhereQueryParams(
      groups: [
        FilterGroup(
          filters: [
            Filter(
              column: 'expiry_date',
              value: date.toIso8601String(),
              operator: FilterOperator.lessOrEqual,
            ),
          ],
        ),
      ],
    );
    await _db.deleteWhere(table: 'alerts', whereParams: params);
  }
}
