import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/get_profile_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';

class UserController extends StateNotifier<UserState> {
  UserController(this._userRepository) : super(UserInitialState());
  final UserRepository _userRepository;

  bool get isUserLoggedIn => _userRepository.isUserLoggedIn;

  User? get currentUser => _userRepository.currentUser;

  Future<void> loadProfile() async {
    try {
      if (currentUser?.id == null) return;

      final profileParams = GetProfileParams(
        userId: currentUser!.id,
        appMetadata: currentUser!.appMetadata,
        userMetadata: currentUser?.userMetadata,
      );

      final newProfile = await _userRepository.getProfile(profileParams);

      state = UserLoadProfileState(newProfile);
    } catch (e, _) {
      state = UserErrorState(state.profile, 'Can\'t get profile error');
    }
  }

  Future<void> updateProfile(ProfileEntity newProfile) async {
    try {
      await _userRepository.updateProfile(newProfile);

      state = UserUpdateProfileState(newProfile);
    } catch (e) {
      state = UserErrorState(state.profile, e.toString());
    }
  }

}
