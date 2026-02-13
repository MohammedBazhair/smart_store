import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/log.dart';
import '../../../../errors/exceptions.dart';
import '../../../user/data/datasources/user_remote_data_source.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<String?> signInWithGoogle();

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
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
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
  Future<String?> signInWithGoogle() async {
    try {
      Logger.debugLog(message: 'Google Sign In');
      const webClientId =
          '711796199152-i0iuh8rvglm0jcgsbae80m9m7cc02pqe.apps.googleusercontent.com';

      const androidClientId =
          '711796199152-05m93odsde25vu2v7vsr4p2p5i3bvaud.apps.googleusercontent.com';

      final signIn = GoogleSignIn.instance;

      await signIn.initialize(
        serverClientId: webClientId,
        clientId: androidClientId,
      );

      // Perform the sign in
      final account = await signIn.authenticate();

      final googleAuthentication = account.authentication;
      final idToken = googleAuthentication.idToken;

      final googleAuthorization = await account.authorizationClient
              .authorizationForScopes(['email', 'profile']) ??
          await account.authorizationClient
              .authorizeScopes(['email', 'profile']);

      final accessToken = googleAuthorization.accessToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }
      final response = await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response.user?.id;
    } catch (e) {
      Logger.debugLog(error: e);
      return null;
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
