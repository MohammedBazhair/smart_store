import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../shared/presentation/theme/app_theme.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../domain/entities/profile.dart';
import '../controllers/user_controller.dart';
import '../controllers/user_state.dart';

class UserProfileWidget extends ConsumerStatefulWidget {
  const UserProfileWidget({super.key});

  @override
  ConsumerState<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends ConsumerState<UserProfileWidget> {
  @override
  void initState() {
    super.initState();
    userController.loadProfile();
    ref.listenManual(userControllerProvider, (previous, next) {
      switch (next) {
        case UserInitialState():
        case UserUpdateProfileState():
          context.showSnakbar('تم تحديث البروفايل بنجاح', type: SnackBarType.success);
        case UserLoadProfileState():
        case UserLoadAvatarState():
          break;
        case UserErrorState(:final message):
          context.showSnakbar(message, type: SnackBarType.error);
      }
    });
  }

  ProfileEntity get profile => ref.watch(userControllerProvider).profile;
  UserController get userController =>
      ref.read(userControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [                    
              if (profile.isEmailLogin)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.edit_rounded, size: 20),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),
          FittedBox(child: Text(profile.username)),
          const SizedBox(height: 5),
          FittedBox(child: Text(userController.currentUser?.email ?? '')),
        ],
      ),
    );
  }
}
