import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/stat_card.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../products/presentation/controllers/product_provider.dart';
import '../../../products/presentation/screens/products_screen.dart';

class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Row(
          spacing: 12,
          children: [
            Consumer(
              builder: (_, ref, __) {
                final productsAsync = ref.watch(productsProvider);

                return StatCard(
                  isShimmerLoading: productsAsync.isLoading,
                  title: 'إجمالي المنتجات',
                  value: productsAsync.value?.length.toString() ?? '0',
                  icon: Icons.inventory_2,
                  color: AppTheme.primaryColor,
                  onTap: () {
                    context.pushTo(
                      ProductsScreen(
                        productsProvider: productsProvider,
                      ),
                    );
                  },
                );
              },
            ),
            Consumer(
              builder: (_, ref, __) {
                final expiredProductsAsync = ref.watch(expiredProductsProvider);

                return StatCard(
                  isShimmerLoading: expiredProductsAsync.isLoading,
                  title: 'منتهية الصلاحية',
                  value: expiredProductsAsync.value?.length.toString() ?? '0',
                  icon: Icons.cancel,
                  color: AppTheme.expiredColor,
                  onTap: () {
                    context.pushTo(
                      ProductsScreen(
                        productsProvider: expiredProductsProvider,
                        title: 'المنتجات منهية الصلاحية',
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        Row(
          spacing: 12,
          children: [
            Consumer(
              builder: (_, ref, __) {
                final newAlertsAsync = ref.watch(newAlertsProvider);

                return StatCard(
                  isShimmerLoading: newAlertsAsync.isLoading,
                  title: 'تنبيهات جديدة',
                  value: newAlertsAsync.value?.length.toString() ?? '0',
                  icon: Icons.notifications,
                  color: AppTheme.primaryColor,
                  onTap: () {
                    context.pushTo(
                      AlertsScreen(
                        title: 'التنبيهات الجديدة',
                        alertsProvider: newAlertsProvider,
                      ),
                    );
                  },
                );
              },
            ),
            Consumer(
              builder: (_, ref, __) {
                final nearExpiryProductsAsync =
                    ref.watch(nearExpiryProductsProvider);

                return StatCard(
                  isShimmerLoading: nearExpiryProductsAsync.isLoading,
                  title: 'قريبة من الانتهاء',
                  value:
                      nearExpiryProductsAsync.value?.length.toString() ?? '0',
                  icon: Icons.warning,
                  color: AppTheme.nearExpiryColor,
                  onTap: () => context.pushTo(
                    ProductsScreen(
                      productsProvider: nearExpiryProductsProvider,
                      title: 'المنتجات قريبة الانتهاء',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
