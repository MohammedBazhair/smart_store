import 'package:flutter/material.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../alerts/presentation/controllers/alert_provider.dart';
import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../products/presentation/screens/add_product_screen.dart';
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
                  context.pushTo(const AddProductScreen());
                },
              ),
            ),
            Expanded(
              child: DashboardQuickActionCard(
                title: 'التنبيهات',
                icon: Icons.notifications_outlined,
                color: AppTheme.warningColor,
                onTap: () {
                  context.pushTo(
                    AlertsScreen(
                      title: 'التنبيهات',
                      alertsProvider: alertsProvider,
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
