import '../../domain/entities/profile.dart';

sealed class UserState {
  UserState(this.profile);
  final ProfileEntity profile;
}

class UserInitialState extends UserState {
  UserInitialState() : super(ProfileEntity.guest());
}

class UserUpdatedProfileState extends UserState {
  UserUpdatedProfileState(super.profile);
}

class UserLoadingProfileState extends UserState {
  UserLoadingProfileState(super.profile);
}

class UserLoadedProfileState extends UserState {
  UserLoadedProfileState(super.profile);
}

class UserErrorState extends UserState {
  UserErrorState(super.profile, this.message);
  final String message;
}
