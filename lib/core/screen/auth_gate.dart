import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/dashboard/presentation/screen/dashboard_screen.dart';
import '../../shared/providers/core_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogged = ref.watch(userControllerProvider.notifier).isUserLoggedIn;

    return isLogged ? const DashboardScreen() : const SignInScreen();
  }
}
