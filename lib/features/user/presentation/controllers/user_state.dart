import '../../domain/entities/profile.dart';

sealed class UserState {

  UserState(this.profile);
  final ProfileEntity profile;
}

class UserInitialState extends UserState {
  UserInitialState() : super(ProfileEntity.guest());
}

class UserUpdateProfileState extends UserState {
  UserUpdateProfileState(super.profile);
}

class UserLoadProfileState extends UserState {
  UserLoadProfileState(super.profile);
}

class UserLoadAvatarState extends UserState {
  UserLoadAvatarState(super.profile);
}

class UserErrorState extends UserState {
  UserErrorState(super.profile, this.message);
  final String message;
}
