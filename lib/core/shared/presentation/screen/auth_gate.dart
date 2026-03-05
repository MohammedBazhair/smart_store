import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../../features/store/presentation/controller/store_provider.dart';
import '../../../../features/store/presentation/controller/store_state.dart';
import '../../../../features/store/presentation/screens/store_selection_screen.dart';
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
      await ref.read(storeControllerProvider.notifier).loadMyStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = ref.watch(userControllerProvider.notifier).isUserLoggedIn;

    if (!isLogged) {
      return const SignInScreen();
    }
    final profile = ref.watch(userControllerProvider).profile;

    final isLoadingStores =
        ref.watch(storeControllerProvider) is LoadinMyStoresEvent;
    if (!profile.isDataComplete || isLoadingStores) {
      return const SplashScreen();
    }

    final stores = ref.watch(storeControllerProvider).state;

    if (stores.selectedStoreId == null) {
      return const StoreSelectionScreen();
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

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              width: 300,
              height: 300,
            ),
            const LoadingWidget(size: 40),
          ],
        ),
      ),
    );
  }
}
