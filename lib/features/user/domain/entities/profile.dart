import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'account_status.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.userId,
    required this.username,
    this.updatedAt,
    required this.accountStatus,
    this.phone,
    this.createdAt,
    required this.credits,
  });

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) return ProfileEntity.guest();
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
    return const ProfileEntity(
      userId: '',
      username: '',
      accountStatus: AccountStatus.pending,
      credits: 0,
    );
  }

  static List<ProfileEntity> get fakeList =>
      List.generate(10, (_) => ProfileEntity.guest());

  final String userId;
  final String username;
  final String? phone;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int credits;
  final AccountStatus accountStatus;

  /// check if user without username and phone
  bool get isDataComplete {
    final hasPhone = phone?.isNotEmpty ?? false;
    return hasPhone && username.isNotEmpty;
  }

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

  Map<String, dynamic> toMapUpdate() {
    final map = toMap()..remove('id');
    return map;
  }

  String toJson() => jsonEncode(toMap());

  @override
  String toString() {
    return 'ProfileEntity(userId: $userId, username: $username, phone: $phone, updatedAt: $updatedAt, createdAt: $createdAt, credits: $credits, accountStatus: $accountStatus)';
  }

  @override
  List<Object?> get props =>
      [userId, username, phone, updatedAt, createdAt, credits, accountStatus];
}
