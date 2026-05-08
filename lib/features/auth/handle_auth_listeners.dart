import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/extensions.dart';
import '../../core/shared/providers/core_providers.dart';
import '../audio/presentation/controller/audio_provider.dart';
import '../user/presentation/screens/account_status_screen.dart';
import 'presentation/controllers/auth_state.dart';
import 'presentation/screens/more_info_screen.dart';
import 'presentation/screens/reconfirm_password_screen.dart';
import 'presentation/screens/sign_in_screen.dart';

Future<void> handlgeAuthListener({
  required BuildContext context,
  required AuthState? previous,
  required AuthState next,
  required WidgetRef ref,
}) async {
  switch (next) {
    case AuthInitialState():
      break;

    case AuthSuccessfullState():
      await ref.read(audioControllerProvider.notifier).playSuccessResult();

      final profile =
          await ref.read(userControllerProvider.notifier).loadProfile();
      if (profile?.isDataComplete ?? false) {
        await OneSignal.login(profile!.phone!);
       
        await context.pushAndRemoveUntilTo(
          AccountStatusScreen(
            profile: profile,
          ),
        );
      } else {
        await context.pushReplacementTo(const MoreInfoScreen());
      }

    case AuthFailedState(:final message):
      context.showSnakbar(message, type: SnackBarType.error);

    case AuthLoadingState():
    case AuthGoogleLoadingState():
      break;
    case AuthResetPasswordSuccessfullState(:final email):
      context.showSnakbar(
        'تم ارسال رمز اعادة تعيين كلمة المرور الى بريدك الالكتروني',
        type: SnackBarType.success,
      );
      await context.pushTo(ReconfirmPasswordScreen(email: email));
    case AuthPasswordChangedSuccessfullState():
      context.showSnakbar(
        'تم تغيير الباسورد بنجاح جرب تسجيل الدخول الان',
        type: SnackBarType.success,
      );
      await context.pushReplacementTo(const SignInScreen());
    case AuthSignOutState():
      context.showSnakbar(
        'تم تسجيل خروجك',
        type: SnackBarType.success,
      );

      await context.pushAndRemoveUntilTo(const SignInScreen());
  }
}
