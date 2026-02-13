import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../errors/exceptions.dart';
import '../../../../errors/result.dart';
import '../../../user/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._networkService, this._cache);
  final AuthRemoteDataSource _remote;
  final ConnectivityService _networkService;
  final LocalCacheService _cache;

  @override
  Future<String?> signUp(UserEntity user) async {
    try {
      final response = await _remote.signUp(user);
      if (response.user == null) throw const AuthException('no id found');

      await _cache.setString(
        key: AppConstants.lastUserIdKey,
        value: response.user!.id,
      );
      return null; // تم التسجيل بنجاح
    } on AuthException catch (e) {
      return _mapSupabaseSignUpError(e.message);
    } catch (e) {
      return 'من فضلك تحقق من اتصالك بالإنترنت';
    }
  }

  @override
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.signIn(email: email, password: password);
      final userId = response.user?.id;

      if (userId != null) {
        await _cache.setString(
          key: AppConstants.lastUserIdKey,
          value: userId,
        );
      }
      return null;
    } on AuthApiException catch (e) {
      return _mapSupabaseSignInError(e.message);
    } catch (e) {
      return 'من فضلك تحقق من اتصالك بالإنترنت';
    }
  }

  @override
  Future<void> signOut() async {
    await _cache.remove(key: AppConstants.lastUserIdKey);
    return _remote.signOut();
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _remote.signInWithGoogle();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String _mapSupabaseSignInError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البيانات المدخلة غير صحيحة';
    }

    if (message.contains('Email not confirmed')) {
      return 'من فضلك قم بتأكيد بريدك الإلكتروني قبل تسجيل الدخول';
    }

    if (message.contains('User not found')) {
      return 'هذا المستخدم غير موجود';
    }

    return 'تسجيل الدخول فشل، يرجى المحاولة مرة أخرى';
  }

  String _mapSupabaseSignUpError(String message) {
    if (message.contains('User already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }

    if (message.contains('password')) {
      return 'كلمة المرور ضعيفة جدًا';
    }

    if (message.contains('email')) {
      return 'من فضلك أدخل بريدًا إلكترونيًا صالحًا';
    }

    return 'التسجيل فشل، يرجى المحاولة مرة أخرى';
  }

  @override
  Future<Result<AuthResponse>> signInWithUrl(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      if (code == null) throw ArgumentError.notNull();

      final authResponse = await _remote.exchangeCodeForAuthSession(code);

      final userId = authResponse.user?.id;

      if (userId == null) throw ArgumentError.notNull();

      await _cache.setString(key: AppConstants.lastUserIdKey, value: userId);
      return SuccessState(authResponse);
    } catch (e) {
      return const ErrorState('فشل تسجيل الدخول، يرجى المحاولة مرة أخرى');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _remote.resetPassword(email);
    } on AuthRetryableFetchException catch (_) {
      throw const InternetException();
    } catch (e) {
      throw const AuthException(
        'فشلت عملية ارسال رسالة الى الايميل واستعادة الباسورد',
      );
    }
  }

  @override
  Future<void> updateUser({
    required String email,
    required String newPassword,
    required String nonce,
  }) async {
    try {
      await _remote.updateUser(
        email: email,
        newPassword: newPassword,
        nonce: nonce,
      );
    } on AppException catch (_) {
      Logger.debugLog(message: 'here');
      rethrow;
    }
  }
}
