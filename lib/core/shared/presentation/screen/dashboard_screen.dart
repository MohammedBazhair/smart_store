import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../errors/result.dart';
import '../../../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../../../features/barcode/presentation/screens/barcode_scanner_screen.dart';
import '../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../features/products/presentation/screens/product_details_screen.dart';
import '../../../../features/settings/presentation/controllers/settings_provider.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../constants/app_constants.dart';
import '../../../extensions/extensions.dart';
import '../../../utils/permissions.dart';
import '../../providers/core_providers.dart';
import '../widgets/dashboard/dashboard_near_expiry_section.dart';
import '../widgets/dashboard/dashboard_quick_actions.dart';
import '../widgets/dashboard/dashboard_stats_section.dart';
import 'permission_denied_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(settingsControllerProvider.notifier);
    });

    _handleInitialNotification();
    checkPermission();
  }

  Future<void> _handleInitialNotification() async {
    final cache = ref.read(localCacheServiceProvider);
    final productId = cache.getString(key: AppConstants.pendingNotificationPayloadKey);
    if (productId == null) return;

    await cache.remove(key: AppConstants.pendingNotificationPayloadKey);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.read(currentProductIdProvider.notifier).state = productId;
        context.pushTo(const ProductDetailsScreen());
      },
    );
  }

  Future<void> checkPermission() async {
    final result = await PermissionsService.requestNotification();

    final isPermiisionDenied = switch (result) {
      ErrorState<bool>() => true,
      SuccessState<bool>(:final data) => !data,
    };

    if (!isPermiisionDenied) return;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context.pushAndRemoveUntilTo(const PermissionDeniedScreen());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        leading: IconButton(
          tooltip: 'التنبيهات',
          icon: const Icon(Icons.notifications_rounded),
          onPressed: () {
            final allAlerts =
                ref.read(alertControllerProvider).allAlerts.values;

            context.pushTo(
              AlertsScreen(
                title: 'التنبيهات',
                alerts: allAlerts.toList(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.pushTo(const SettingsScreen());
            },
          ),
        ],
      ),
      body: const DashboardBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'مسح الباركود',
        shape: const CircleBorder(),
        elevation: 2.5,
        onPressed: () {
          context.pushTo(const BarcodeScannerScreen());
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}

class DashboardBody extends ConsumerWidget {
  const DashboardBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    return RefreshIndicator(
      onRefresh: () async {
        final controller = ref.read(productControllerProvider.notifier);
        await controller.initialize();
        await ref.read(alertControllerProvider.notifier).loadAlerts();
      },
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 30,
          children: [
            DashboardStatsSection(),
            DashboardQuickActions(),
            DashboardNearExpirySection(),
          ],
        ),
      ),
    );
  }
}
