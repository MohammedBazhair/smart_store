import '../../../../features/user/domain/entities/role.dart';
import 'permission.dart';

class RolePermissions {
  RolePermissions._();
  static const Map<Role, Set<PermissionTask>> map = {
    Role.guest: {},
    Role.worker: {
      PermissionTask.addProduct,
      PermissionTask.updateProduct,
      PermissionTask.scanBarcodeViewPrice,
      PermissionTask.viewStoreProducts,
    },
    Role.storeOwner: {
      PermissionTask.fullAccess,
    },
  };
}
