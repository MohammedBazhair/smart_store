import '../../domain/entities/store_member.dart';

class StoreMemberModel extends StoreMember {
  const StoreMemberModel({
    super.id,
    required super.memberPhone,
    required super.storeId,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoreMemberModel.fromEntity(StoreMember member) {
    return StoreMemberModel(
      id: member.id,
      memberPhone: member.memberPhone,
      storeId: member.storeId,
      role: member.role,
      createdAt: member.createdAt,
      updatedAt: member.updatedAt,
    );
  }

  factory StoreMemberModel.fromMap(Map<String, dynamic> map) {
    return StoreMemberModel(
      id: map['id'],
      memberPhone: map['member_phone'],
      storeId: map['store_id'],
      role: map['role'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'member_phone': memberPhone,
      'store_id': storeId,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
