import 'package:flutter/material.dart';
import '../../../../core/extensions/extensions.dart';
import '../../exchange_rates_management/presentation/screens/exchange_rates_screen.dart';
import '../../products_management/presentation/screens/all_products_screen.dart';
import '../../stores_management/presentation/screens/all_stores_screen.dart';
import '../../users_management/presentation/screens/manage_users_screen.dart';
import '../widgets/dashboard_admin_card.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            onPressed: () => context.pushTo(const AdminProfileScreen()),
            icon: const Icon(Icons.person_rounded),
          ),
        ],
      ),
      body: _DashboardGrid(),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 1200 ? 4 : (width > 800 ? 3 : 2);
        final aspectRatio = width > 600 ? 1.3 : 1.1;
        return GridView.count(
          padding: const EdgeInsets.all(24),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: aspectRatio,
          children: [
            DashboardAdminCard(
              title: 'إدارة المستخدمين',
              icon: Icons.people_alt_rounded,
              onTap: () => context.pushTo(const ManageUsersScreen()),
            ),
            DashboardAdminCard(
              title: 'إدارة المتاجر',
              icon: Icons.storefront_rounded,
              onTap: () => context.pushTo(const AllStoresScreen()),
            ),
            DashboardAdminCard(
              title: 'إدارة المنتجات',
              icon: Icons.inventory_2_rounded,
              onTap: () => context.pushTo(const AllProductsScreen()),
            ),
            DashboardAdminCard(
              title: 'تغيير أسعار الصرف',
              icon: Icons.price_change_rounded,
              onTap: () => context.pushTo(const ExchangesRatesScreen()),
            ),
          ],
        );
      },
    );
  }
}
