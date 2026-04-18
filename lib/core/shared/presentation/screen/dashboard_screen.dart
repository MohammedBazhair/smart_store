import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../errors/result.dart';
import '../../../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../../../features/barcode/presentation/screens/barcode_scanner_screen.dart';
import '../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../features/settings/presentation/controllers/settings_provider.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../extensions/extensions.dart';
import '../../../utils/permissions.dart';
import '../widgets/dashboard/dashboard_products_section.dart';
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

    checkPermission();
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
                ref.read(alertControllerProvider).allAlerts.values.toList();

            context.pushTo(
              AlertsScreen(
                title: 'التنبيهات',
                alerts: allAlerts,
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
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'مسح الباركود',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 2.5,
        onPressed: () {
          context.pushTo(const BarcodeScannerScreen());
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('فحص منتج'),
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
            DashboardProductsSection(),
          ],
        ),
      ),
    );
  }
}
