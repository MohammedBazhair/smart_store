import '../../domain/entities/profile.dart';

class UserStateEntity {
  UserStateEntity({
    required this.profile,
    this.isLogged = false,
    this.isInitilized = false,
  });

  final ProfileEntity profile;
  final bool isLogged;
  final bool isInitilized;

  UserStateEntity copyWith({
    ProfileEntity? profile,
    bool? isLogged,
    bool? isInitilized,
  }) {
    return UserStateEntity(
      profile: profile ?? this.profile,
      isLogged: isLogged ?? this.isLogged,
      isInitilized: isInitilized ?? this.isInitilized,
    );
  }
}

sealed class UserState {
  UserState(this.entity);
  final UserStateEntity entity;
}

class UserInitialState extends UserState {
  UserInitialState(super.entity);
}

class UserUpdatedProfileState extends UserState {
  UserUpdatedProfileState(super.entity);
}

class UserLoadingProfileState extends UserState {
  UserLoadingProfileState(super.entity);
}

class UserLoadedProfileState extends UserState {
  UserLoadedProfileState(super.entity);
}

class UserMoreInfoProfileState extends UserState {
  UserMoreInfoProfileState(super.entity);
}

class UserErrorState extends UserState {
  UserErrorState(
    super.entity, {
    required this.message,
  });
  final String message;
}
