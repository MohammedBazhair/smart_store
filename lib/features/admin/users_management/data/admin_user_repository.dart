import '../../../user/data/datasources/user_remote_data_source.dart';
import '../../../user/domain/entities/profile.dart';

class AdminUserRepository {
  AdminUserRepository(this._userRemote);

  final UserRemoteDataSource _userRemote;

  Future<Map<String, ProfileEntity>> getAllUsers() async {
    final response = await _userRemote.fetchProfiles();
    final users = response.map((m) {
      final profile = ProfileEntity.fromMap(m);

      return MapEntry(profile.userId, profile);
    });
    return Map.fromEntries(users);
  }

  Future<void> updateUserStatus(ProfileEntity updated) {
    return _userRemote.updateProfile(updated);
  }

  Future<ProfileEntity> addCredits(
    String userId,
    int amountToAdd,
  ) async {
    final profile = await _userRemote.readProfile(userId);
    final currentCredits = profile.credits;
    final updatedCredits = currentCredits + amountToAdd;

    final updatedDate = DateTime.now().toUtc();
    final updatedProfile =
        profile.copyWith(credits: updatedCredits, updatedAt: updatedDate);

    await _userRemote.updateProfile(updatedProfile);
    return updatedProfile;
  }
}
