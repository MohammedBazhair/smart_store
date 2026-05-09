import '../../../../user/domain/entities/profile.dart';

class AdminUsersState {
  const AdminUsersState({
    this.isLoading = false,
    this.users = const {},
  });
  final bool isLoading;
  final Map<String, ProfileEntity> users;

  AdminUsersState copyWith({
    bool? isLoading,
    Map<String, ProfileEntity>? users,
  }) {
    return AdminUsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
    );
  }
}
