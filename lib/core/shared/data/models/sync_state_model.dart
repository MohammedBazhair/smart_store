class SyncStateModel {
  const SyncStateModel({
    required this.tableName,
    required this.lastSync,
  });

  factory SyncStateModel.fromMap(Map<String, dynamic> map) {
    return SyncStateModel(
      tableName: map['table_name'],
      lastSync: DateTime.parse(map['last_sync']),
    );
  }
  final String tableName;
  final DateTime lastSync;

  Map<String, dynamic> toMap() {
    return {
      'table_name': tableName,
      'last_sync': lastSync.toIso8601String(),
    };
  }

  SyncStateModel copyWith({
    String? tableName,
    DateTime? lastSync,
  }) {
    return SyncStateModel(
      tableName: tableName ?? this.tableName,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}
