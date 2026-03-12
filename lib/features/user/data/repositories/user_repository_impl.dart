import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../domain/entities/get_profile_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._auth,
    this._sync,
    this._connectivityService,
  );
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final SyncLocalDataSource _sync;
  final ConnectivityService _connectivityService;
  final GoTrueClient _auth;

  @override
  bool get isUserLoggedIn => _auth.currentUser != null;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<ProfileEntity> getProfile(GetProfileParams params) async {
    try {
      final profileModel = await _remoteDataSource.readProfile(params.userId);

      await _localDataSource.upsertProfile(profileModel);
      return profileModel;
    } catch (e) {
      debugPrint(e.toString());
      return _localDataSource.readProfile(params.userId);
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();

      if (hasConnection) await _remoteDataSource.updateProfile(profile);

      await _localDataSource.upsertProfile(profile, hasConnection);
    } catch (e) {
      Logger.debugLog(error: e);
      rethrow;
    }
  }

  @override
  Future<bool> isPhoneSignUp(String phoneNumber) {
    return _remoteDataSource.isPhoneSignUp(phoneNumber);
  }

  Future<void> _pushProfileChanges() async {
    final changes = await _sync.getTableChanges(AppConstants.profilesTable);

    for (final change in changes) {
      if (change.operation != SyncOperation.update) continue;

      final userId = change.recordId;
      final profile = await _localDataSource.readProfile(userId);

      await _remoteDataSource.updateProfile(profile);

      await _sync.deleteChange(change.id!);
    }
  }

  @override
  Future<ProfileEntity> syncProfile() async {
    await _pushProfileChanges();

    final userId = currentUser?.id;
    if (userId == null) return _localDataSource.readProfile();

    final remoteProfile = await _remoteDataSource.readProfile(userId);

    await _localDataSource.upsertProfile(remoteProfile, true);

    return remoteProfile;
  }
}
