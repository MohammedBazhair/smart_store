import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../../features/user/domain/entities/account_status.dart';
import '../../../../features/user/presentation/screens/account_status_screen.dart';
import '../../providers/core_providers.dart';
import '../widgets/common/loading_widget.dart';
import 'dashboard_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(userControllerProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = ref.watch(userControllerProvider.notifier).isUserLoggedIn;

    if (!isLogged) {
      return const SignInScreen();
    }
    final profile = ref.watch(userControllerProvider).profile;

    if (!profile.isDataComplete) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/app_logo.png',
                width: 200,
                height: 200,
              ),
              const LoadingWidget(),
            ],
          ),
        ),
      );
    }

    switch (profile.accountStatus) {
      case AccountStatus.active:
        return const DashboardScreen();
      case AccountStatus.frozen:
      case AccountStatus.pending:
        return AccountStatusScreen(profile: profile);
    }
  }
}
