import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../../../features/user/presentation/screens/account_status_screen.dart';
import '../../providers/core_providers.dart';
import '../../providers/repositories_provider.dart';
import 'dashboard_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogged = ref.watch(userControllerProvider.notifier).isUserLoggedIn;

    if (!isLogged) {
      return const SignInScreen();
    }

    // User is logged in, check if we should show account status
    return FutureBuilder<bool>(
      future: _shouldShowAccountStatus(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final shouldShow = snapshot.data ?? false;

        if (shouldShow) {
          final userState = ref.watch(userControllerProvider);
          final profile = userState.profile;

          return AccountStatusScreen(
            profile: profile,
           
          );
        }

        return const DashboardScreen();
      },
    );
  }

  Future<bool> _shouldShowAccountStatus(WidgetRef ref) async {
    // Check if shown before in persistent storage
    final prefs = ref.read(sharedPreferencesProvider);
    final hasShownBefore = prefs.getBool('has_shown_account_status') ?? false;

    return !hasShownBefore;
  }
}
