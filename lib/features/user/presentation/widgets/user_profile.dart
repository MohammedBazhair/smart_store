import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../domain/entities/profile.dart';
import '../controllers/user_controller.dart';
import '../handle_user_states.dart';

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
    ref.listenManual(userControllerProvider, (_, state) {
      handleUserStates(state, context);
    });
  }

  ProfileEntity get profile => ref.watch(userControllerProvider).entity.profile;
  UserController get userController =>
      ref.read(userControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          FittedBox(child: Text(profile.username)),
          const SizedBox(height: 5),
          FittedBox(child: Text(userController.currentUser?.email ?? '')),
        ],
      ),
    );
  }
}
