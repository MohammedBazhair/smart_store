import 'package:flutter/material.dart';
import '../../../../core/extensions/extensions.dart';
import '../../products_management/presentation/screens/all_products_screen.dart';
import '../../stores_management/presentation/screens/all_stores_screen.dart';
import '../../users_management/presentation/screens/manage_users_screen.dart';
import '../widgets/dashboard_admin_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Row(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _AdminAppBar(isDesktop: isDesktop),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  sliver: _DashboardGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAppBar extends StatelessWidget {
  const _AdminAppBar({required this.isDesktop});
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: !isDesktop,
      leading: isDesktop ? const SizedBox.shrink() : null,
      title: const Text(
        'نظرة عامة على النظام',
        style: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.5,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CircleAvatar(
            backgroundColor: Color(0xFFEDF2F7),
            child: Icon(Icons.person_outline, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.crossAxisExtent;
        final int crossAxisCount = width > 1200 ? 4 : (width > 800 ? 3 : 2);

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: width > 600 ? 1.3 : 1.1,
          ),
          delegate: SliverChildListDelegate([
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
              title: 'الإعدادات العامة',
              icon: Icons.admin_panel_settings_rounded,
              onTap: () {},
            ),
          ]),
        );
      },
    );
  }
}
