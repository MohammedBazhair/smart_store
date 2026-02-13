import '../../domain/entities/app_user.dart';
import '../../domain/entities/sub/auth_provider.dart';

class AppUserModel extends AppUser {
  AppUserModel({
    required super.name,
    required super.email,
    required super.avatarUrl,
    required super.provider,
    required this.emailVerified,
    required this.googleId,
    required this.issuer,
    required this.phoneVerified,
    required this.providers,
    required this.userId,
     super.updatedAt,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel.fromSupabase(
      appMetadata: map['raw_app_meta_data'],
      userMetadata: map['raw_user_meta_data'],
      userId: map['id'],
      updatedAt: DateTime.tryParse(map['updated_at']??''),
    );
  }

  factory AppUserModel.fromSupabase({
    required Map<String, dynamic>? userMetadata,
    required Map<String, dynamic> appMetadata,
    required String userId,
    DateTime? updatedAt,

  }) {
    final rawProviders = appMetadata['providers'] as List<dynamic>? ?? [];

    final providers = rawProviders
        .map((e) => AuthProvider.fromString(e.toString()))
        .toList();

    return AppUserModel(
      userId: userId,
      name: userMetadata?['full_name'] ?? '',
      email: userMetadata?['email'] ?? '',
     updatedAt: updatedAt,
      emailVerified: userMetadata?['email_verified'] ?? false,
      avatarUrl: userMetadata?['avatar_url'] ?? '',
      googleId: userMetadata?['provider_id'] ?? '',
      issuer: userMetadata?['iss'] ?? '',
      phoneVerified: userMetadata?['phone_verified'] ?? false,
      provider: AuthProvider.fromString(appMetadata['provider'] ?? ''),
      providers: providers,
    );
  }

  final String userId;
  final bool emailVerified;
  final String? googleId;
  final String issuer;
  final bool phoneVerified;
  final List<AuthProvider> providers;
}
