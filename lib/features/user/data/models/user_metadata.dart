class UserMetadata {
  UserMetadata({
    this.avatarUrl,
    this.email,
    this.emailVerified,
    this.fullName,
    this.name,
    this.picture,
    this.providerId,
    this.sub,
    this.issuer,
    this.phoneVerified,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) {
    return UserMetadata(
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      emailVerified: json['email_verified'] as bool?,
      fullName: json['full_name'] as String?,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
      providerId: json['provider_id'] as String?,
      sub: json['sub'] as String?,
      issuer: json['iss'] as String?,
      phoneVerified: json['phone_verified'] as bool?,
    );
  }
  final String? avatarUrl;
  final String? email;
  final bool? emailVerified;
  final String? fullName;
  final String? name;
  final String? picture;
  final String? providerId;
  final String? sub;
  final String? issuer;
  final bool? phoneVerified;

   @override
  String toString() {
    return 'UserMetadata('
        'email: $email, '
        'fullName: $fullName, '
        'name: $name, '
        'avatarUrl: $avatarUrl, '
        'picture: $picture, '
        'providerId: $providerId'
        ')';
  }
}
