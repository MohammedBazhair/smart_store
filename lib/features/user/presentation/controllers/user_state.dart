import 'package:equatable/equatable.dart';

import '../../domain/entities/profile.dart';

class UserStateEntity extends Equatable {
  const UserStateEntity({
    required this.profile,
    this.isLogged = false,
  });

  final ProfileEntity profile;
  final bool isLogged;

  UserStateEntity copyWith({
    ProfileEntity? profile,
    bool? isLogged,
  }) {
    return UserStateEntity(
      profile: profile ?? this.profile,
      isLogged: isLogged ?? this.isLogged,
    );
  }

  @override
  List<Object?> get props => [isLogged, profile];
}

sealed class UserState extends Equatable {
  const UserState(this.entity);
  final UserStateEntity entity;

  @override
  List<Object?> get props => [entity];
}

class UserInitialState extends UserState {
  const UserInitialState(super.entity);

}

class UserUpdatedProfileState extends UserState {
  const UserUpdatedProfileState(super.entity);

}

class UserLoadingProfileState extends UserState {
  const UserLoadingProfileState(super.entity);
}

class UserLoadedProfileState extends UserState {
  const UserLoadedProfileState(super.entity);
}

class UserMoreInfoProfileState extends UserState {
  const UserMoreInfoProfileState(super.entity);
}

class UserErrorState extends UserState {
  const UserErrorState(
    super.entity, {
    required this.message,
  });
  final String message;
}
