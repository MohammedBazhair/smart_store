import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/database_helper.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/exceptions.dart';
import '../../../../errors/result.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitialState();

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);

  Future<void> loginWithGoogle() async {
    try {
      state = const AuthGoogleLoadingState();
      final userId = await _authRepo.signInWithGoogle();
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
      final result = await _authRepo.signInWithUrl(uri);
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
    final error = await _authRepo.signIn(email: email, password: password);

    _handleState(error);
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AuthLoadingState();

    final error = await _authRepo.signUp(email: email, password: password);

    _handleState(error);
  }

  Future<void> signOut() async {
    try {
      await _authRepo.signOut();

      await _refreshWhenSignOut();

      state = const AuthSignOutState();
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      _handleState('حدث خطأ في الخروج حاول مرة أخرى');
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AuthLoadingState();
    try {
      await _authRepo.resetPassword(email);
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
      await _authRepo.updateUser(
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

  Future<void> _refreshWhenSignOut() async {
    ref.invalidate(userControllerProvider);
    ref.invalidate(storeControllerProvider);
    ref.invalidate(appSyncControllerProvider);
    await DatabaseHelper.instance.close();
  }
}
