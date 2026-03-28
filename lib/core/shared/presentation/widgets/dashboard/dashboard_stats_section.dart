import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../../../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../../features/products/presentation/screens/products_screen.dart';
import '../../../../extensions/extensions.dart';
import '../../theme/app_theme.dart';
import '../common/stat_card.dart';

class DashboardStatsSection extends StatelessWidget {
  const DashboardStatsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        Consumer(
          builder: (_, ref, __) {
            final products = ref
                .watch(
                  productControllerProvider.select((s) => s.products),
                )
                .values;
    
            return StatCard(
              title: 'إجمالي المنتجات',
              value: products.length.toString(),
              icon: Icons.inventory_2,
              color: AppTheme.primaryColor,
              onTap: () {
                context.pushTo(
                  ProductsScreen(
                    products: products.toList(),
                  ),
                );
              },
            );
          },
        ),
        Consumer(
          builder: (_, ref, __) {
            final expiredProducts = ref.watch(
              productControllerProvider.select((s) => s.expiredProducts),
            );
    
            return StatCard(
              title: 'منتهية الصلاحية',
              value: expiredProducts.length.toString(),
              icon: Icons.cancel,
              color: AppTheme.expiredColor,
              onTap: () {
                context.pushTo(
                  ProductsScreen(
                    products: expiredProducts,
                    title: 'المنتجات منهية الصلاحية',
                  ),
                );
              },
            );
          },
        ),
        Consumer(
          builder: (_, ref, __) {
            final newAlerts = ref.watch(
              alertControllerProvider.select((s) => s.newAlerts),
            );
    
            return StatCard(
              title: 'تنبيهات جديدة',
              value: newAlerts.length.toString(),
              icon: Icons.notifications,
              color: AppTheme.primaryColor,
              onTap: () {
                context.pushTo(
                  AlertsScreen(
                    title: 'التنبيهات الجديدة',
                    alerts: newAlerts.values.toList(),
                  ),
                );
              },
            );
          },
        ),
        Consumer(
          builder: (_, ref, __) {
            final nearExpiryProducts = ref.watch(
              productControllerProvider
                  .select((s) => s.nearbyExpiredProducts),
            );
    
            return StatCard(
              title: 'قريبة من الانتهاء',
              value: nearExpiryProducts.length.toString(),
              icon: Icons.warning,
              color: AppTheme.nearExpiryColor,
              onTap: () => context.pushTo(
                ProductsScreen(
                  products: nearExpiryProducts,
                  title: 'المنتجات قريبة الانتهاء',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
