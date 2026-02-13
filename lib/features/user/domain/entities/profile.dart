import 'dart:convert';

import '../../../auth/data/model/app_user.dart';
import '../../../auth/domain/entities/sub/auth_provider.dart';
import 'account_status.dart';
import 'role.dart';

class ProfileEntity {
  ProfileEntity({
    required this.userId,
    required this.username,
    this.updatedAt,
    this.authProviders = const {},
    required this.role,
    required this.accountStatus,
    this.phone,
    this.createdAt,
  });

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    return ProfileEntity(
      userId: map['id'] as String,
      phone: map['phone'] as String?,
      role: Role.fromString(map['role'] as String),
      username: map['user_name'] as String,
      accountStatus: AccountStatus.fromString(map['account_status'] as String),
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  factory ProfileEntity.fromJson(String source) {
    final map = jsonDecode(source);
    return ProfileEntity.fromMap(map);
  }

  factory ProfileEntity.fromEntity(ProfileEntity profile) {
    return ProfileEntity(
      userId: profile.userId,
      username: profile.username,
      authProviders: profile.authProviders,
      updatedAt: profile.updatedAt,
      accountStatus: profile.accountStatus,
      role: profile.role,
      createdAt: profile.createdAt,
      phone: profile.phone,
    );
  }

  factory ProfileEntity.guest() {
    return ProfileEntity(
      userId: '',
      username: '',
      updatedAt: DateTime.now().toUtc(),
      accountStatus: AccountStatus.pending,
      role: Role.guest,
    );
  }

  factory ProfileEntity.fromAppUser(AppUserModel model) {
    return ProfileEntity(
      userId: model.userId,
      username: model.userId,
      updatedAt: model.updatedAt,
      authProviders: model.providers.toSet(),
      accountStatus: AccountStatus.pending,
      role: Role.guest,
    );
  }

  final String userId;
  final String username;
  final String? phone;
  final Set<AuthProvider> authProviders;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final Role role;
  final AccountStatus accountStatus;

  bool get isEmailLogin => authProviders.contains(AuthProvider.email);
  bool get isDataComplete => phone != null && username.isNotEmpty;

  ProfileEntity copyWith({
    String? userId,
    String? username,
    String? phone,
    Set<AuthProvider>? authProviders,
    DateTime? updatedAt,
    DateTime? createdAt,
    Role? role,
    AccountStatus? accountStatus,
  }) {
    return ProfileEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      authProviders: authProviders ?? this.authProviders,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': userId,
      'phone': phone,
      'role': role.name,
      'user_name': username,
      'account_status': accountStatus.name,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());
}
