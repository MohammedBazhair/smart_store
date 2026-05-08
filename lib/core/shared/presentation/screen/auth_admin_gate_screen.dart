import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../providers/core_providers.dart';
import 'splash_screen.dart';

class AuthAdminGate extends ConsumerWidget {
  const AuthAdminGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogged =
        ref.watch(userControllerProvider.select((s) => s.entity.isLogged));

    if (!isLogged) return const SignInScreen();

    final profile =
        ref.watch(userControllerProvider.select((s) => s.entity.profile));

    if (!profile.isDataComplete) return const SplashScreen();

    return const AdminDashboardScreen();
  }
}
