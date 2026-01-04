import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../shared/presentation/theme/app_theme.dart';
import '../../../domain/product_details.dart';
import '../../controllers/product_provider.dart';
import '../../screens/add_product_screen.dart';

class BaseProductInfoCard extends ConsumerWidget {
  const BaseProductInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.detailsType,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final ProductDetailsType detailsType;
  final Color iconColor;

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      child: ListTile(
        onTap: () {
          final product = ref.read(currentProductProvider);
          context.pushTo(
            AddProductScreen(
              product: product,
              detailsType: detailsType,
            ),
          );
        },
        title: Row(
          spacing: 8,
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}

class ProductInfoCard extends ConsumerWidget {
  const ProductInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.detailsType,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final ProductDetailsType detailsType;
  final Color iconColor;

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        onTap: () {
          final product = ref.read(currentProductProvider);
          context.pushTo(
            AddProductScreen(
              product: product,
              detailsType: detailsType,
            ),
          );
        },
        title: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.08),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
            ),
          ],
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}
