import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../errors/exceptions.dart';
import '../../../user/data/datasources/user_remote_data_source.dart';
import '../../../user/domain/entities/user.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp(UserEntity user);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> signInWithGoogle();

  Future<AuthResponse> exchangeCodeForAuthSession(String code);

  Future<void> resetPassword(String email);

  Future<void> updateUser({
    required String email,
    required String newPassword,
    required String nonce,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._auth, this._userRemote);
  final GoTrueClient _auth;
  final UserRemoteDataSource _userRemote;

  @override
  Future<AuthResponse> signUp(UserEntity user) {
    return _auth.signUp(
      email: user.email,
      password: user.password,
      data: {'full_name': user.username, 'avatar_url': null},
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      const webClientId =
          '711796199152-i0iuh8rvglm0jcgsbae80m9m7cc02pqe.apps.googleusercontent.com';

      final GoogleSignIn signIn = GoogleSignIn.instance;

      unawaited(
        signIn.initialize(serverClientId: webClientId),
      );

      // Perform the sign in
      final googleAccount = await signIn.authenticate();
      final googleAuthorization =
          await googleAccount.authorizationClient.authorizationForScopes([]);
      final googleAuthentication = googleAccount.authentication;
      final idToken = googleAuthentication.idToken;
      final accessToken = googleAuthorization?.accessToken;

      if (idToken == null || accessToken == null) {
        throw 'No ID Token or Access Token found.';
      }

       await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<AuthResponse> exchangeCodeForAuthSession(String code) async {
    final response = await _auth.exchangeCodeForSession(code);

    return AuthResponse(session: response.session, user: response.session.user);
  }

  @override
  Future<void> resetPassword(String email) {
    return _auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updateUser({
    required String email,
    required String newPassword,
    required String nonce,
  }) async {
    try {
      await _auth.verifyOTP(type: OtpType.recovery, token: nonce, email: email);

      await _auth.updateUser(
        UserAttributes(nonce: nonce, email: email, password: newPassword),
      );
    } on AuthException catch (_) {
      throw const OtpWrongException();
    }
  }
}
