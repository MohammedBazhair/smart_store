import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
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

            final isLoading =
                ref.watch(productControllerProvider.select((s) => s.isLoading));
            return Skeletonizer(
              enabled: isLoading,
              child: StatCard(
                title: 'إجمالي المنتجات',
                value: products.length.toString(),
                icon: Icons.inventory_2,
                color: AppTheme.primaryColor,
                onTap: () {
                  context.pushTo(
                    const ProductsScreen(),
                  );
                },
              ),
            );
          },
        ),
        Consumer(
          builder: (_, ref, __) {
            final unreadAlerts = ref.watch(
              alertControllerProvider.select((s) => s.unreadAlerts),
            );

            return StatCard(
              title: 'تنبيهات جديدة',
              value: unreadAlerts.length.toString(),
              icon: Icons.notifications,
              color: AppTheme.primaryColor,
              onTap: () {
                context.pushTo(
                  AlertsScreen(
                    title: 'التنبيهات الجديدة',
                    alerts: unreadAlerts.values.toList(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
