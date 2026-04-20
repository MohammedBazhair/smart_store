import 'package:flutter/material.dart';
import '../../../../../features/cashier/presentation/screens/checkout_screen.dart';
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
                title: 'المحاسب',
                icon: Icons.point_of_sale_outlined,
                color: Colors.green,
                onTap: () {
                  context.pushTo(const CheckoutScreen());
                },
              ),
            ),
            Expanded(
              child: DashboardQuickActionCard(
                title: 'إضافة منتج',
                icon: Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                onTap: () {
                  context.pushTo(const UpsertProductScreen());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
