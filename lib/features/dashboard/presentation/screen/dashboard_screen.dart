import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/screen/permission_denied_screen.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../core/utils/result.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../../alerts/presentation/controllers/notification_cache.dart';
import '../../../barcode/presentation/screens/barcode_scanner_screen.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/dashboard_near_expiry_section.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_stats_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _handleInitialNotification();
    checkPermission();
  FlutterNativeSplash.remove();

  }

  Future<void> _handleInitialNotification() async {
    final productId = await NotificationCache.read();
    if (productId == null) return;

    await NotificationCache.clear();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context.pushTo(ProductDetailsScreen(productId: productId));
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
        context.pushReplacementTo(const PermissionDeniedScreen());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.pushTo(const SettingsScreen());
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (_, ref, __) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productsProvider);
              ref.invalidate(expiredProductsProvider);
              ref.invalidate(nearExpiryProductsProvider);
              ref.invalidate(newAlertsProvider);
            },
            child: const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24,
                children: [
                  DashboardStatsGrid(),
                  DashboardQuickActions(),
                  DashboardNearExpirySection(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 2.5,
        onPressed: () {
          context.pushTo(const BarcodeScannerScreen());
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('مسح الباركود'),
      ),
    );
  }
}
