import 'dart:convert';
import '../../../auth/domain/entities/sub/auth_provider.dart';
import '../../domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.userId,
    required super.username,
    required super.updatedAt,
    required super.credits,
    super.authProviders,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      userId: map['id'] as String,
      username: map['username'] as String,
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
      credits: map['credits'] as int,
    );
  }

  factory ProfileModel.fromJson(String source) {
    final map = jsonDecode(source);
    return ProfileModel.fromMap(map);
  }

  factory ProfileModel.fromEntity(ProfileEntity profile) {
    return ProfileModel(
      userId: profile.userId,
      username: profile.username,
      authProviders: profile.authProviders,
      updatedAt: profile.updatedAt,
      credits: profile.credits,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': userId,
      'username': username,
      'updated_at': updatedAt?.toUtc().toIso8601String(),
      'credits': credits,
    };
  }

  String toJson() => jsonEncode(toMap());

  @override
  ProfileModel copyWith({
    String? userId,
    String? username,
    DateTime? updatedAt,
    Set<AuthProvider>? authProviders,
    int? credits,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      updatedAt: updatedAt ?? this.updatedAt,
      authProviders: authProviders ?? this.authProviders,
      credits: credits ?? this.credits,
    );
  }
}
