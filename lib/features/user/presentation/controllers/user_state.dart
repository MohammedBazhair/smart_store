import '../../domain/entities/profile.dart';

sealed class UserState {
  UserState({required this.profile, this.isLogged = false});
  final ProfileEntity profile;
  final bool isLogged;
}

class UserInitialState extends UserState {
  UserInitialState({required super.isLogged}) : super(profile: ProfileEntity.guest());
}

class UserUpdatedProfileState extends UserState {
  UserUpdatedProfileState({required super.profile,required super.isLogged});
}

class UserLoadingProfileState extends UserState {
  UserLoadingProfileState({required super.profile, required super.isLogged});
}

class UserLoadedProfileState extends UserState {
  UserLoadedProfileState({required super.profile, required super.isLogged});
}

class UserMoreInfoProfileState extends UserState {
  UserMoreInfoProfileState({required super.profile, required super.isLogged});
}

class UserErrorState extends UserState {
  UserErrorState({
    required super.profile,
   required super.isLogged,
    required this.message,
  });
  final String message;
}
