import 'package:flutter/material.dart';
import '../../../../../features/cashier/presentation/screens/pos_screen.dart';
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
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            DashboardQuickActionCard(
              title: 'المحاسب',
              icon: Icons.point_of_sale_outlined,
              color: Colors.green,
              onTap: () {
                context.pushTo(const PosScreen());
              },
            ),
            DashboardQuickActionCard(
              title: 'إضافة منتج',
              icon: Icons.add_circle_outline,
              color: AppTheme.primaryColor,
              onTap: () {
                context.pushTo(const UpesertProductScreen());
              },
            ),
          ],
        ),
      ],
    );
  }
}
