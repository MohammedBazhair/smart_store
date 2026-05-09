import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../constants/log.dart';
import '../../providers/core_providers.dart';
import 'splash_screen.dart';

class AuthAdminGate extends ConsumerStatefulWidget {
  const AuthAdminGate({super.key});

  @override
  ConsumerState<AuthAdminGate> createState() => _AuthAdminGateState();
}

class _AuthAdminGateState extends ConsumerState<AuthAdminGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userControllerProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = ref.watch(
      userControllerProvider.select((s) => s.entity.isLogged),
    );

    if (!isLogged) {
      return const SignInScreen();
    }

    final isComplete = ref.watch(
      userControllerProvider.select(
        (s) => s.entity.profile.isDataComplete,
      ),
    );

    if (!isComplete) {
      Logger.debugLog(message: 'Loading...');
      return const SplashScreen();
    }

    return const AdminDashboardScreen();
  }
}
