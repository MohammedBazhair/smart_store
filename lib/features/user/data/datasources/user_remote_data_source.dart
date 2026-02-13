import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/database/remote/remote_database_service.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

abstract interface class UserRemoteDataSource {
  Future<void> createProfile(ProfileEntity profile);

  Future<ProfileEntity> readProfile(String? userId);

  Future<void> updateProfile(ProfileEntity profile, [String? avatrPath]);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(
    this._client,
    this._remoteDatabase,
    this._locaCache,
  );
  final SupabaseClient _client;
  final RemoteDatabaseService _remoteDatabase;
  final LocalCacheService _locaCache;

  @override
  Future<void> createProfile(ProfileEntity profile) {
    final profileModel = ProfileModel(
      userId: profile.userId,
      username: profile.username,
      updatedAt: profile.updatedAt,
      credits: 10,
    );

    return _remoteDatabase.insertRow(
      map: profileModel.toMap(),
      table: AppConstants.profilesTable,
    );
  }

  @override
  Future<ProfileEntity> readProfile(String? userId) async {
    try {
      if (userId == null) throw ArgumentError.notNull('userId');

      final map = await _remoteDatabase.readRow(
        id: userId,
        column: 'id',
        table: AppConstants.profilesTable,
      );

      final profileModel = ProfileModel.fromMap(map);

      final profileEntity = ProfileEntity(
        userId: userId,
        username: profileModel.username,
        updatedAt: profileModel.updatedAt,
        credits: profileModel.credits,
      );

      return profileEntity;
    } catch (e) {
      debugPrint(e.toString());

      rethrow;
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile, [String? avatrPath]) async {
    if (profile.userId.isEmpty) throw ArgumentError.value(profile.userId);

    final profileMap = await _remoteDatabase.readRow(
      id: profile.userId,
      column: 'id',
      table: AppConstants.profilesTable,
    );

    final profileModel = ProfileModel.fromMap(profileMap);

    final updatedModel = profileModel.copyWith(
      authProviders: profile.authProviders,
      username: profile.username,
      updatedAt: DateTime.now().toUtc(),
    );

    await _remoteDatabase.update(
      updated: updatedModel.toMap(),
      id: profile.userId,
      column: 'id',
      table: AppConstants.profilesTable,
    );
  }
}
