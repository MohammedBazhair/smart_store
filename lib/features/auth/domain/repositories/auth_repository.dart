
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../errors/result.dart';
import '../../../user/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<String?> signUp(UserEntity user);

  Future<String?> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> signInWithGoogle();
    
  Future<Result<AuthResponse>> signInWithUrl(Uri uri);

  Future<void> resetPassword(String email);

 Future<void> updateUser({
    required String email,
    required String newPassword,
    required String nonce,
  });

}

