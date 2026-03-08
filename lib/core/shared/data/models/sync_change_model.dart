import 'package:equatable/equatable.dart';

import '../../../constants/enums.dart';

class SyncChangeModel extends Equatable {
  const SyncChangeModel({
    this.id,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.updatedAt,
  });

  factory SyncChangeModel.fromMap(Map<String, dynamic> map) {
    return SyncChangeModel(
      id: map['id'],
      tableName: map['table_name'],
      recordId: map['record_id'],
      operation: SyncOperation.fromString(map['operation']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
  final int? id;
  final String tableName;
  final String recordId;
  final SyncOperation operation;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation.name,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SyncChangeModel copyWith({
    int? id,
    String? tableName,
    String? recordId,
    SyncOperation? operation,
    DateTime? updatedAt,
  }) {
    return SyncChangeModel(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [tableName, recordId, operation];
}
