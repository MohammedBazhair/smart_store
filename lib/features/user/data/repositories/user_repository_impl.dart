import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/log.dart';
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
      final profileModel = await _remoteDataSource.readProfile(params.userId);

      await _localDataSource.saveProfile(profileModel);
      return profileModel;
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
      Logger.debugLog(error: e);
      rethrow;
    }
  }
}
