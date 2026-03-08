import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/extensions/extensions.dart';
import 'controllers/user_state.dart';
import 'screens/account_status_screen.dart';

void handleUserStates(
  UserState state,
  BuildContext context,
) {
  switch (state) {
    case UserInitialState():
    case UserLoadingProfileState():
    case UserLoadedProfileState():
      break;
    case UserUpdatedProfileState():
      context.showSnakbar(
        'تم تحديث البروفايل بنجاح',
        type: SnackBarType.success,
      );
    case UserErrorState(:final message):
      context.showSnakbar(message, type: SnackBarType.error);
    case UserMoreInfoProfileState(:final profile):
      context.pushReplacementTo(
        AccountStatusScreen(
          profile: profile,
        ),
      );
  }
}
