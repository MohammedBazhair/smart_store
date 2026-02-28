import 'package:equatable/equatable.dart';

import '../../../user/domain/entities/role.dart';

class StoreMember extends Equatable {
  const StoreMember({
    this.id,
    required this.memberPhone,
    required this.storeId,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
  final String? id;
  final String memberPhone;
  final String storeId;
  final Role role;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [memberPhone, storeId, role, createdAt, updatedAt];
}
