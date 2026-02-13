import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/get_profile_params.dart';
import '../entities/profile.dart';

abstract interface class UserRepository {
  bool get isUserLoggedIn;
  User? get currentUser;

  Future<ProfileEntity> getProfile(GetProfileParams params);

  Future<void> updateProfile(ProfileEntity profile);

}
