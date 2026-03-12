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

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context,ref) {
    final isLogged = ref.watch(userControllerProvider.notifier).isUserLoggedIn;

    if (!isLogged) {
      return const SignInScreen();
    }
    final appSync = ref.watch(appSyncProvider);
    final profile = ref.watch(userControllerProvider).profile;

final storeState = ref.watch(storeControllerProvider);
    final isLoadingStores = storeState is LoadinMyStoresEvent;

    if (!profile.isDataComplete || isLoadingStores || appSync.isLoading) {
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
