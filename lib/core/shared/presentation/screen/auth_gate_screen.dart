import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../../features/store/presentation/controller/store_provider.dart';
import '../../../../features/store/presentation/controller/store_state.dart';
import '../../../../features/store/presentation/screens/store_selection_screen.dart';
import '../../../../features/user/domain/entities/account_status.dart';
import '../../../../features/user/presentation/screens/account_status_screen.dart';
import '../../../extensions/extensions.dart';
import '../../providers/core_providers.dart';
import 'dashboard_screen.dart';
import 'splash_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isLogged = ref.watch(userControllerProvider.notifier).isUserLoggedIn;

    if (!isLogged) return const SignInScreen();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screen = switch (profile.accountStatus) {
        AccountStatus.active => const DashboardScreen(),
        AccountStatus.frozen => AccountStatusScreen(profile: profile),
        AccountStatus.pending => AccountStatusScreen(profile: profile),
      };

      context.pushAndRemoveUntilTo(screen);
    });

      return const SplashScreen();

  }
}
