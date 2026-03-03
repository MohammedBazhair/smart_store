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
                  final productsAsync = ref.watch(productsProvider);
              
                  Widget _child(int length) {
                    return StatCard(
                      title: 'إجمالي المنتجات',
                      value: '$length',
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
                  }
              
                  return productsAsync.when(
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
                  final expiredProductsAsync = ref.watch(expiredProductsProvider);
              
                  Widget _child(int length) {
                    return StatCard(
                      title: 'منتهية الصلاحية',
                      value: '$length',
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
                  }
              
                  return expiredProductsAsync.when(
                    data: (data) => _child(data.length),
                    loading: () => Skeletonizer(child: _child(0)),
                    error: (error, stackTrace) => _child(0),
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
                  final nearExpiryProductsAsync =
                      ref.watch(nearExpiryProductsProvider);
              
              
                  Widget _child(int length) {
                    return StatCard(
                      title: 'قريبة من الانتهاء',
                      value:
                          '$length',
                      icon: Icons.warning,
                      color: AppTheme.nearExpiryColor,
                      onTap: () => context.pushTo(
                        ProductsScreen(
                          productsProvider: nearExpiryProductsProvider,
                          title: 'المنتجات قريبة الانتهاء',
                        ),
                      ),
                    );
                  }
              
                  return nearExpiryProductsAsync.when(
                    data: (data) => _child(data.length),
                    loading: () => Skeletonizer(child: _child(0)),
                    error: (error, stackTrace) => _child(0),
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
