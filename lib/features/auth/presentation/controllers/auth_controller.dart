import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/log.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/exceptions.dart';
import '../../../../errors/result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final auth = ref.read(authProvider);
  return auth;
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._auth) : super(const AuthInitialState());
  final AuthRepository _auth;

  Future<void> loginWithGoogle() async {
    try {
      state = const AuthGoogleLoadingState();
      final userId = await _auth.signInWithGoogle();
      if (userId == null) {
        throw const AuthAppException('فشل تسجيل الدخول');
      }

      state = const AuthSuccessfullState();
    } on AuthAppException catch (e) {
      state = AuthFailedState(e.message);
    } catch (e) {
      state = AuthFailedState('فشل تسجيل الدخول');
    }
  }

  Future<void> loginWithUri(Uri uri) async {
    try {
      final result = await _auth.signInWithUrl(uri);
      if (result case ErrorState(:final message)) {
        throw AuthAppException(message);
      }

      state = const AuthSuccessfullState();
    } on AuthAppException catch (e) {
      Logger.debugLog(error: e.message);
      state = AuthFailedState(e.message);
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoadingState();
    final error = await _auth.signIn(email: email, password: password);

    _handleState(error);
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AuthLoadingState();

    final error = await _auth.signUp(email: email, password: password);

    _handleState(error);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      state = const AuthSignOutState();
    } catch (e) {
      _handleState('حدث خطأ في الخروج حاول مرة أخرى');
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AuthLoadingState();
    try {
      await _auth.resetPassword(email);
      state = AuthResetPasswordSuccessfullState(email);
    } on AppException catch (e) {
      state = AuthFailedState(e.message);
    } catch (e) {
      state = AuthFailedState('فشلت عملية استعادة الباسورد حاول مرة أخرى');
    }
  }

  Future<void> changePassword({
    required String email,
    required String newPassword,
    required String nonce,
  }) async {
    state = const AuthLoadingState();
    try {
      await _auth.updateUser(
        email: email,
        newPassword: newPassword,
        nonce: nonce,
      );
      state = const AuthPasswordChangedSuccessfullState();
    } on AppException catch (e) {
      state = AuthFailedState(e.message);
    } catch (e) {
      state = AuthFailedState('فشلت عملية استعادة الباسورد حاول مرة أخرى');
    }
  }

  void _handleState(String? error) {
    state =
        error == null ? const AuthSuccessfullState() : AuthFailedState(error);
  }
}
