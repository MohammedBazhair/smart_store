import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/typedef.dart';
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
  Future<void> setProfiles(RowList maps);
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

  @override
  Future<void> setProfiles(RowList maps) async {
    final aleradyProfiles =
        await _localService.rawQuery(query: 'SELECT id FROM profiles');

    final ids = aleradyProfiles.map((m) => m['id'] as String).toSet();

    final batch = _localService.batch;

    for (final element in maps) {
      final userId = element['id'] as String?;
      if (userId == null) continue;

      if (ids.contains(userId)) {
        final map = {...element}..remove('id');
        batch.update(
          AppConstants.profilesTable,
          map,
          where: 'id = ? AND updated_at < ?',
          whereArgs: [userId, element['updated_at']],
        );
      } else {
        batch.insert(
          AppConstants.profilesTable,
          element,
            conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    await batch.commit(noResult: true);
  }
}
