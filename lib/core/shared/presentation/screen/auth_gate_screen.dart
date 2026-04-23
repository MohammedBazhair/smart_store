import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../features/products/presentation/screens/product_details_screen.dart';
import '../../../../features/store/presentation/controller/store_provider.dart';
import '../../../../features/store/presentation/screens/store_selection_screen.dart';
import '../../../../features/user/domain/entities/account_status.dart';
import '../../../../features/user/presentation/screens/account_status_screen.dart';
import '../../../constants/app_constants.dart';
import '../../../extensions/extensions.dart';
import '../../providers/core_providers.dart';
import 'dashboard_screen.dart';
import 'splash_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(userControllerProvider).entity.isLogged) return;

      ref.read(appSyncControllerProvider.notifier).sync();
      _handleNotificationAppLaunch();
    });
  }

  Future<void> _handleNotificationAppLaunch() async {
    final cache = ref.read(localCacheServiceProvider);
    final productId =
        cache.getString(key: AppConstants.pendingNotificationPayloadKey);
    if (productId == null || productId.isEmpty) return;

    await cache.remove(key: AppConstants.pendingNotificationPayloadKey);

    ref.read(currentProductIdProvider.notifier).state = productId;
    await context.pushTo(const ProductDetailsScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isLogged =
        ref.watch(userControllerProvider.select((s) => s.entity.isLogged));

    if (!isLogged) return const SignInScreen();

    final profile = ref.watch(userControllerProvider.select((s)=>s.entity.profile));

    final isStoresInitialized =
        ref.watch(storeControllerProvider.select((s) => s.state.isInitialized));

    if (!profile.isDataComplete || !isStoresInitialized) {
      return const SplashScreen();
    }

    final stores = ref.watch(storeControllerProvider).state;

    if (stores.selectedStoreId == null) {
      return const StoreSelectionScreen();
    }

    final screen = switch (profile.accountStatus) {
      AccountStatus.active => const DashboardScreen(),
      AccountStatus.frozen => AccountStatusScreen(profile: profile),
      AccountStatus.pending => AccountStatusScreen(profile: profile),
    };

    return screen;
  }
}
