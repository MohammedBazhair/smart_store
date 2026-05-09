import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/providers/core_providers.dart';
import '../../data/admin_user_repository.dart';
import 'admin_users_controller.dart';
import 'admin_users_search_controller.dart';
import 'admin_users_state.dart';

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  final _userRemote = ref.read(userRemoteDataSourceProvider);
  return AdminUserRepository(_userRemote);
});

final adminUsersControllerProvider =
    NotifierProvider<AdminUsersController, AdminUsersState>(
  AdminUsersController.new,
);

final adminUsersSearchControllerProvider =
    NotifierProvider<AdminUsersSearchController, AdminUsersSearchState>(
  AdminUsersSearchController.new,
);
