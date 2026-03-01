import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../domain/entities/profile.dart';

abstract interface class UserLocalDataSource {
  Future<void> saveProfile(ProfileEntity profile);
  Future<ProfileEntity> readProfile();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._localService, this._cacheService);

  final LocalDatabaseService _localService;
  final LocalCacheService _cacheService;

  @override
  Future<void> saveProfile(ProfileEntity profile) async {
    await _localService.insertRow(
      map: profile.toMap(),
      table: AppConstants.profilesTable,
    );
    await _cacheService.setString(
      key: AppConstants.profileUserIdKey,
      value: profile.userId,
    );
  }

  @override
  Future<ProfileEntity> readProfile() async {
    final id = _cacheService.getString(key: AppConstants.profileUserIdKey);
    if (id == null) return ProfileEntity.guest();

    final raw = await _localService.readRow(
      id: id,
      column: 'id',
      table: AppConstants.profilesTable,
    );

    return ProfileEntity.fromMap(raw);
  }
}
