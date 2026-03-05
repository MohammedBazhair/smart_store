import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/log.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/get_profile_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';

class UserController extends StateNotifier<UserState> {
  UserController(this._userRepository) : super(UserInitialState());
  final UserRepository _userRepository;

  bool get isUserLoggedIn => _userRepository.isUserLoggedIn;

  User? get currentUser => _userRepository.currentUser;

  Future<ProfileEntity?> loadProfile() async {
    try {
      state = UserLoadingProfileState(state.profile);
      if (currentUser?.id == null) return null;

      final profileParams = GetProfileParams(
        userId: currentUser!.id,
        appMetadata: currentUser!.appMetadata,
        userMetadata: currentUser?.userMetadata,
      );

      final newProfile = await _userRepository.getProfile(profileParams);

      state = UserLoadedProfileState(newProfile);
      return newProfile;
    } catch (e, _) {
      Logger.debugLog(error: e);
      state = UserErrorState(state.profile, 'Can\'t get profile error');
      return null;
    }
  }

  Future<Result<void>> updateProfile(ProfileEntity newProfile) async {
    try {
      await _userRepository.updateProfile(newProfile);
      state = UserUpdatedProfileState(newProfile);
      return const SuccessState(null);
    } catch (e) {
      Logger.debugLog(error: e);
      state = UserErrorState(
        state.profile,
        'حصل خطا أثناء التحديث معلومات المستخدم',
      );
      return ErrorState(e.toString());
    }
  }
}
