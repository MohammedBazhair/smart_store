import 'sub/auth_provider.dart';

class AppUser {
  AppUser({required this.name, required this.email, required this.avatarUrl, required this.provider,  this.updatedAt});

  final String name;
  final DateTime? updatedAt;
  final String email;
  final String? avatarUrl;
  final AuthProvider provider; // google, facebook, email...

}