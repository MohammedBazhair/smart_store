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
    final stateEntity = UserStateEntity(
      profile: ProfileEntity.guest(),
      isLogged: currentUser != null,
    );

    return UserInitialState(stateEntity);
  }

  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  User? get currentUser => _userRepository.currentUser;

  Future<ProfileEntity?> loadProfile() async {
    try {
      if (state.entity.isInitilized) return state.entity.profile;
      // منع الاستدعاء المزدوج
      if (state is UserLoadingProfileState) return null;

      state = UserLoadingProfileState(state.entity);
      if (currentUser?.id == null) return null;

      final profileParams = GetProfileParams.fromSupabaseUser(currentUser!);

      ProfileEntity newProfile =
          await _userRepository.getProfile(profileParams);

      if (!newProfile.isDataComplete) {
        newProfile = newProfile.copyWith(
          username: profileParams.userMetadata?.fullName,
          phone: profileParams.phone,
        );
      }

      if (!ref.mounted) return null;

      state = UserLoadedProfileState(
        state.entity
            .copyWith(profile: newProfile, isLogged: true, isInitilized: true),
      );
      
      return newProfile;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = UserErrorState(
        state.entity,
        message: 'حدث خطأ... لم نتمكن من الحصول على بيانات بروفايلك',
      );
      return null;
    }
  }

  Future<Result<void>> updateProfile(ProfileEntity newProfile) async {
    try {
      await _userRepository.updateProfile(newProfile);
      state = UserUpdatedProfileState(
        state.entity.copyWith(profile: newProfile),
      );
      return const SuccessState(null);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = UserErrorState(
        state.entity,
        message: 'حصل خطا أثناء التحديث معلومات المستخدم',
      );
      return ErrorState(e.toString());
    }
  }
}
