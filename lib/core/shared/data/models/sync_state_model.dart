class SyncStateModel {
  const SyncStateModel({
    required this.tableName,
    required this.lastSynced,
  });

  factory SyncStateModel.fromMap(Map<String, dynamic> map) {
    return SyncStateModel(
      tableName: map['table_name'],
      lastSynced: DateTime.parse(map['last_sync']),
    );
  }
  final String tableName;
  final DateTime lastSynced;

  Map<String, dynamic> toMap() {
    return {
      'table_name': tableName,
      'last_sync': lastSynced.toIso8601String(),
    };
  }

  SyncStateModel copyWith({
    String? tableName,
    DateTime? lastSynced,
  }) {
    return SyncStateModel(
      tableName: tableName ?? this.tableName,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }
}
