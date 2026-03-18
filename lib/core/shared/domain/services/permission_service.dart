import '../../../../features/user/domain/entities/account_status.dart';
import '../../../../features/user/domain/entities/role.dart';
import '../entities/permission.dart';
import '../entities/role_permissions.dart';

class PermissionService {
  PermissionService({required this.role, required this.accountStatus});

  final Role role;
  final AccountStatus accountStatus;

  bool can(PermissionTask permission) {
    if (accountStatus != AccountStatus.active) {
      return false;
    }

    final permissions = RolePermissions.map[role];

    if (permissions == null || permissions.isEmpty) return false;

    if (permissions.contains(PermissionTask.fullAccess)) {
      return true;
    }

    return permissions.contains(permission);
  }
}
