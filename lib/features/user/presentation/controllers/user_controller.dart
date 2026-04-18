import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/get_profile_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';

class UserController extends Notifier<UserState> {
  @override
  UserState build() {
    return UserInitialState(isLogged: currentUser != null);
  }

  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  User? get currentUser => _userRepository.currentUser;

  Future<ProfileEntity?> loadProfile() async {
    try {
      state = UserLoadingProfileState(
        profile: state.profile,
        isLogged: state.isLogged,
      );
      if (currentUser?.id == null) return null;

      final profileParams = GetProfileParams(
        userId: currentUser!.id,
        appMetadata: currentUser!.appMetadata,
        userMetadata: currentUser?.userMetadata,
      );

      final newProfile = await _userRepository.getProfile(profileParams);

      state = UserLoadedProfileState(profile: newProfile, isLogged: true);
      return newProfile;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = UserErrorState(
        profile: state.profile,
        message: 'حدث خطأ... لم نتمكن من الحصول على بيانات بروفايلك',
        isLogged: state.isLogged,
      );
      return null;
    }
  }

  Future<Result<void>> updateProfile(ProfileEntity newProfile) async {
    try {
      await _userRepository.updateProfile(newProfile);
      state = UserUpdatedProfileState(
        profile: newProfile,
        isLogged: state.isLogged,
      );
      return const SuccessState(null);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = UserErrorState(
        profile: state.profile,
        message: 'حصل خطا أثناء التحديث معلومات المستخدم',
        isLogged: state.isLogged,
      );
      return ErrorState(e.toString());
    }
  }
}
