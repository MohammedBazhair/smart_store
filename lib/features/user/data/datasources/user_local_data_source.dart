import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/shared/data/models/sync_change_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../domain/entities/profile.dart';

abstract interface class UserLocalDataSource {
  Future<void> upsertProfile(
    ProfileEntity profile, [
    bool skipLocalTracking = false,
  ]);
  Future<ProfileEntity> readProfile([String? userId]);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._localService, this._cacheService, this._sync);

  final LocalDatabaseService _localService;
  final LocalCacheService _cacheService;
  final SyncLocalDataSource _sync;

  @override
  Future<void> upsertProfile(
    ProfileEntity profile, [
    bool skipLocalTracking = false,
  ]) async {
    await _cacheService.setString(
      key: AppConstants.profileUserIdKey,
      value: profile.userId,
    );

    final existingRow = await _localService.readRow(
      id: profile.userId,
      column: 'id',
      table: AppConstants.profilesTable,
    );

    final isNew = existingRow.isEmpty;

    if (isNew) {
      await _localService.insertRow(
        map: profile.toMap(),
        table: AppConstants.profilesTable,
      );
    } else {
      await _localService.update(
        filterWhere: {'id': profile.userId},
        updated: profile.toMapUpdate(),
        table: AppConstants.profilesTable,
      );
    }

    if (skipLocalTracking) return;

    final change = SyncChangeModel(
      tableName: AppConstants.profilesTable,
      recordId: profile.userId,
      operation: isNew ? SyncOperation.insert : SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );
    await _sync.addChange(change);
  }

  @override
  Future<ProfileEntity> readProfile([String? userId]) async {
    final id =
        userId ?? _cacheService.getString(key: AppConstants.profileUserIdKey);
    if (id == null) return ProfileEntity.guest();

    final map = await _localService.readRow(
      id: id,
      column: 'id',
      table: AppConstants.profilesTable,
    );

    return ProfileEntity.fromMap(map);
  }
}
