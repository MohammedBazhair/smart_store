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
            Expanded(
              child: Consumer(
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
            ),
            Expanded(
              child: Consumer(
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
            ),
          ],
        ),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: Consumer(
                builder: (_, ref, __) {
                  final newAlertsAsync = ref.watch(newAlertsProvider);

                  Widget _child(int length) {
                    return StatCard(
                      title: 'تنبيهات جديدة',
                      value: '$length',
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
                  }

                  return newAlertsAsync.when(
                    data: (data) => _child(data.length),
                    loading: () => Skeletonizer(child: _child(0)),
                    error: (error, stackTrace) => _child(0),
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer(
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
            ),
          ],
        ),
      ],
    );
  }
}
