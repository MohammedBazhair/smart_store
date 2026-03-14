import 'package:equatable/equatable.dart';

import '../../../user/domain/entities/role.dart';
import '../../data/models/store_member_key.dart';

class StoreMember extends Equatable {
  const StoreMember({
    required this.primaryKey,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final bool isDeleted;
  final StoreMemberKey primaryKey;
  final Role role;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [primaryKey, role, createdAt, updatedAt,isDeleted];

  @override
  bool get stringify => true;
}
