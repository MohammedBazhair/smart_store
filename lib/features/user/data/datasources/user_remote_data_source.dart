import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/database/remote/remote_database_service.dart';
import '../../domain/entities/profile.dart';

abstract interface class UserRemoteDataSource {
  Future<ProfileEntity> readProfile(String? userId);

  Future<void> updateProfile(ProfileEntity profile);

  Future<bool> isPhoneSignUp(String phoneNumber);
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
  Future<ProfileEntity> readProfile(String? userId) async {
    try {
      if (userId == null) throw ArgumentError.notNull('userId');

      final map = await _remoteDatabase.readRow(
        id: userId,
        column: 'id',
        table: AppConstants.profilesTable,
      );

      return ProfileEntity.fromMap(map);
    } catch (e) {
      debugPrint(e.toString());

      rethrow;
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    if (profile.userId.isEmpty) throw ArgumentError.value(profile.userId);

    final updated = profile.copyWith(updatedAt: DateTime.now());

    await _remoteDatabase.update(
      updated: updated.toMap(),
      whereFilter: {'id': profile.userId},
      table: AppConstants.profilesTable,
    );
  }

  @override
  Future<bool> isPhoneSignUp(String phoneNumber) async {
    final response = await _remoteDatabase.client
        .from('profiles')
        .select('phone')
        .eq('phone', phoneNumber);
    return response.isNotEmpty;
  }
}
