import 'package:flutter/material.dart';

import '../../../../../shared/presentation/theme/app_theme.dart';
import '../../../domain/product_details.dart';

class BaseProductInfoCard extends StatelessWidget {
  const BaseProductInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.detailsType,
  });

  final IconData icon;
  final String label;
  final String value;
  final ProductDetailsType detailsType;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (detailsType == ProductDetailsType.price) {
          // context.pushTo(const AddProductScreen(product: ,));
        }
      },
      title: Row(
        spacing: 8,
        children: [
          Icon(icon),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
        ],
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 25),
      ),
    );
  }
}

class ProductInfoCard extends StatelessWidget {
  const ProductInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.detailsType,
  });

  final IconData icon;
  final String label;
  final String value;
  final ProductDetailsType detailsType;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListTile(
        onTap: () {
          switch (detailsType) {
            case ProductDetailsType.price:

            case ProductDetailsType.quantity:

            case ProductDetailsType.category:

            case ProductDetailsType.barcode:

            case ProductDetailsType.expiryDate:

            case ProductDetailsType.notes:

            case ProductDetailsType.name:
          }
        },
        title: Column(
          spacing: 8,
          children: [
            CircleAvatar(child: Icon(icon)),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
            ),
          ],
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
