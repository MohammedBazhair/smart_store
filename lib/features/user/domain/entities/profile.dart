import 'dart:convert';

import 'account_status.dart';

class ProfileEntity {
  ProfileEntity({
    required this.userId,
    required this.username,
    this.updatedAt,
    required this.accountStatus,
    this.phone,
    this.createdAt,
    required this.credits,
  });

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    return ProfileEntity(
      userId: map['id'] as String,
      phone: map['phone'] as String?,
      username: map['user_name'] as String,
      credits: map['credits'] as int,
      accountStatus: AccountStatus.fromString(map['account_status'] as String),
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  factory ProfileEntity.fromJson(String source) {
    final map = jsonDecode(source);
    return ProfileEntity.fromMap(map);
  }

  factory ProfileEntity.guest() {
    return ProfileEntity(
      userId: '',
      username: '',
      updatedAt: DateTime.now().toUtc(),
      accountStatus: AccountStatus.pending,
      credits: 0,
    );
  }

  final String userId;
  final String username;
  final String? phone;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int credits;
  final AccountStatus accountStatus;

  bool get isDataComplete => phone != null && username.isNotEmpty;

  ProfileEntity copyWith({
    String? userId,
    String? username,
    String? phone,
    DateTime? updatedAt,
    DateTime? createdAt,
    AccountStatus? accountStatus,
    int? credits,
  }) {
    return ProfileEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      credits: credits ?? this.credits,
      phone: phone ?? this.phone,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'phone': phone,
      'credits': credits,
      'user_name': username,
      'account_status': accountStatus.name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  @override
  String toString() {
    return 'ProfileEntity(userId: $userId, username: $username, phone: $phone, updatedAt: $updatedAt, createdAt: $createdAt, credits: $credits, accountStatus: $accountStatus)';
  }
}
