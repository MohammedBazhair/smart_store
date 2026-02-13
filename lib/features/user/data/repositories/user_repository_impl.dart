import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/model/app_user.dart';
import '../../../auth/domain/entities/sub/auth_provider.dart';
import '../../domain/entities/get_profile_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource, this._localDataSource, this._auth);
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final GoTrueClient _auth;

  @override
  bool get isUserLoggedIn => _auth.currentUser != null;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<ProfileEntity> getProfile(GetProfileParams params) async {
    try {
      final appUser = AppUserModel.fromSupabase(
        userId: params.userId,
        userMetadata: params.userMetadata,
        appMetadata: params.appMetadata,
      );
      final providers = appUser.providers.toSet();

      final ProfileEntity profileEntity;
      final profile = await _remoteDataSource.readProfile(params.userId);
      switch (appUser.provider) {
        case AuthProvider.email:
          profileEntity = profile.copyWith(authProviders: providers);
        case AuthProvider.google:
          profileEntity = ProfileEntity(
            userId: params.userId,
            username: appUser.name,
            authProviders: providers,
            credits: profile.credits,
          );

        case AuthProvider.unknown:
          throw Exception('unKnown provider, try again');
      }

      await _localDataSource.saveProfile(profileEntity);
      return profileEntity;
    } catch (e) {
      debugPrint(e.toString());
      return _localDataSource.readProfile();
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      await _remoteDataSource.updateProfile(profile);
    } catch (e) {
      throw Exception('Failed to update ${profile.username} profile');
    }
  }
}
