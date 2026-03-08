import 'package:equatable/equatable.dart';

import '../../../user/domain/entities/role.dart';

class StoreMember extends Equatable {
  const StoreMember({
    required this.memberPhone,
    required this.storeId,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final bool isDeleted;
  final String memberPhone;
  final String storeId;
  final Role role;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [memberPhone, storeId, role, createdAt, updatedAt,isDeleted];

  @override
  bool get stringify => true;
}
