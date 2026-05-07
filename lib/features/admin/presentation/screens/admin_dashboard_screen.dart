import 'package:flutter/material.dart';

import '../../products_management/presentation/screens/all_products_screen.dart';
import '../../stores_management/presentation/screens/all_stores_screen.dart';
import '../../users_management/presentation/screens/manage_users_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            context,
            title: 'إدارة المستخدمين',
            icon: Icons.people,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            title: 'إدارة المتاجر',
            icon: Icons.store,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllStoresScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            title: 'إدارة المنتجات',
            icon: Icons.inventory,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllProductsScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            title: 'الإعدادات',
            icon: Icons.settings,
            onTap: () {
              // TODO: Navigate to admin settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
