import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../../../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../../../../features/products/presentation/screens/upsert_product_screen.dart';
import '../../../../extensions/extensions.dart';
import '../../theme/app_theme.dart';
import 'dashboard_quick_action_card.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'إجراءات سريعة',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: DashboardQuickActionCard(
                title: 'إضافة منتج',
                icon: Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                onTap: () {
                  context.pushTo(const UpesertProductScreen());
                },
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (_, ref, __) {
                  final allAlerts =
                      ref.watch(alertControllerProvider).allAlerts.values;
                  return DashboardQuickActionCard(
                    title: 'التنبيهات',
                    icon: Icons.notifications_outlined,
                    color: AppTheme.warningColor,
                    onTap: () {
                      context.pushTo(
                        AlertsScreen(
                          title: 'التنبيهات',
                          alerts: allAlerts.toList(),
                        ),
                      );
                    },
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
