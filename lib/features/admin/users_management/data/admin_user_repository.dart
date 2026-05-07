import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../user/domain/entities/profile.dart';

class AdminUserRepository {
  AdminUserRepository(this._client);

  final SupabaseClient _client;

  Future<List<ProfileEntity>> getAllUsers() async {
    final response = await _client.from(AppConstants.profilesTable).select();
    return response.map((e) => ProfileEntity.fromMap(e)).toList();
  }

  Future<List<ProfileEntity>> searchUsers(String query) async {
    final response = await _client
        .from(AppConstants.profilesTable)
        .select()
        .or('phone.ilike.%$query%,user_name.ilike.%$query%');

    return response.map((e) => ProfileEntity.fromMap(e)).toList();
  }

  Future<void> updateUserStatus(String userId, String status) async {
    await _client
        .from(AppConstants.profilesTable)
        .update({
          'account_status': status,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', userId);
  }

  Future<void> addCredits(String userId, int currentCredits, int amountToAdd) async {
    await _client
        .from(AppConstants.profilesTable)
        .update({
          'credits': currentCredits + amountToAdd,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', userId);
  }
}
