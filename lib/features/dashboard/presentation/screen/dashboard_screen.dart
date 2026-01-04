import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../../barcode/presentation/screens/barcode_scanner_screen.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/dashboard_near_expiry_section.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_stats_grid.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: RefreshIndicator(
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
