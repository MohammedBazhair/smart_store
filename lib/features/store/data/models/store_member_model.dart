import '../../../../core/extensions/extensions.dart';
import '../../../user/domain/entities/role.dart';
import '../../domain/entities/store_member.dart';
import 'store_member_key.dart';

class StoreMemberModel extends StoreMember {
  const StoreMemberModel({
    required super.primaryKey,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
     super.isDeleted,
  });

  factory StoreMemberModel.fromEntity(StoreMember member) {
    return StoreMemberModel(
      primaryKey: member.primaryKey,
      role: member.role,
      createdAt: member.createdAt,
      updatedAt: member.updatedAt,
      isDeleted: member.isDeleted,
    );
  }

  factory StoreMemberModel.fromMap(Map<String, dynamic> map) {
    return StoreMemberModel(
      primaryKey: StoreMemberKey.fromMap(map),
      role: Role.fromString(map['role']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ...primaryKey.toMap(),
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted.toInt,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('store_id')
      ..remove('member_phone');
  }
}
