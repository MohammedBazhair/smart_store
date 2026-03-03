import '../../../user/domain/entities/role.dart';
import '../../domain/entities/store_member.dart';

class StoreMemberModel extends StoreMember {
  const StoreMemberModel({
    required super.memberPhone,
    required super.storeId,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoreMemberModel.fromEntity(StoreMember member) {
    return StoreMemberModel(
      memberPhone: member.memberPhone,
      storeId: member.storeId,
      role: member.role,
      createdAt: member.createdAt,
      updatedAt: member.updatedAt,
    );
  }

  factory StoreMemberModel.fromMap(Map<String, dynamic> map) {
    return StoreMemberModel(
      memberPhone: map['member_phone'],
      storeId: map['store_id'],
      role:Role.fromString( map['role']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'member_phone': memberPhone,
      'store_id': storeId,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
