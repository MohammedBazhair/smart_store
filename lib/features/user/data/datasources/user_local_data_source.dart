import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../domain/entities/profile.dart';

abstract interface class UserLocalDataSource {
  Future<void> saveProfile(ProfileEntity profile);
  Future<ProfileEntity> readProfile();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._cacheService);

  final LocalCacheService _cacheService;

  @override
  Future<void> saveProfile(ProfileEntity profile) async {
    await _cacheService.setString(
      key: AppConstants.profileUserKey,
      value: profile.toJson(),
    );
  }

  @override
  Future<ProfileEntity> readProfile() async {
    final raw = _cacheService.getString(key: AppConstants.profileUserKey);
    if (raw == null) return ProfileEntity.guest();

    final model = ProfileEntity.fromJson(raw);

    return model;
  }
}
