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
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Consumer(
            builder: (_, ref, __) {
              final products = ref
                  .watch(
                    productControllerProvider.select((s) => s.products),
                  )
                  .values;

              final isLoading = ref
                  .watch(productControllerProvider.select((s) => s.isLoading));
              return Skeletonizer(
                enabled: isLoading,
                child: StatCard(
                  title: 'إجمالي المنتجات',
                  value: products.length.toString(),
                  asset: 'assets/icons/products-icon.svg',
                  iconSize: 40,
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
        ),
        Expanded(
          child: Consumer(
            builder: (_, ref, __) {
              final unreadAlertsLength = ref.watch(
                alertControllerProvider.select((s) => s.unreadAlerts.length),
              );

              return StatCard(
                title: 'تنبيهات جديدة',
                value: unreadAlertsLength.toString(),
                asset: 'assets/icons/notification-alert-icon.svg',
                iconSize: 30,
                color: AppTheme.primaryColor,
                onTap: () {
                  context.pushTo(
                    const AlertsScreen(
                      title: 'التنبيهات الجديدة',
                      alertsScreenType: AlertsScreenType.unRead,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
