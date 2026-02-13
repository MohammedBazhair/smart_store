import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/extensions.dart';

import '../../shared/presentation/widgets/common/custom_progress_widget.dart';
import '../dashboard/presentation/screen/dashboard_screen.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/auth_state.dart';
import 'presentation/screens/reconfirm_password_screen.dart';
import 'presentation/screens/sign_in_screen.dart';

Future<void> authListener({
  required BuildContext context,
  required AuthState? previous,
  required AuthState next,
  required WidgetRef ref,
}) async {
  if (previous is AuthLoadingState) context.pop();

  switch (next) {
    case AuthInitialState():
      break;

    case AuthSuccessfullState():
      await context.pushReplacementTo(const DashboardScreen());

    case AuthFailedState(:final message):
      context.showSnakbar(message, type: SnackBarType.error);

    case AuthLoadingState():
      await showDialog(
        context: context,
        builder: (context) => const CustomProgressWidget(),
      );
      await ref.read(authProvider.notifier).startLoadingTimeout();
    case AuthResetPasswordSuccessfullState(:final email):
      context.showSnakbar(
        'تم ارسال رمز اعادة تعيين كلمة المرور الى بريدك الالكتروني', type: SnackBarType.success,
      );
      await context.pushTo(ReconfirmPasswordScreen(email: email));
    case AuthPasswordChangedSuccessfullState():
      context.showSnakbar(
        'تم تغيير الباسورد بنجاح جرب تسجيل الدخول الان', type: SnackBarType.success,
      );
      await context.pushReplacementTo(const SignInScreen());
  }
}
