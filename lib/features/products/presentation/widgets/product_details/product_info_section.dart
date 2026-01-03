import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../domain/product.dart';
import '../../../domain/product_details.dart';
import 'product_info_card.dart';

class ProductInfoSection extends StatelessWidget {
  const ProductInfoSection({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final remainingTime =
        date_utils.DateUtils.timeUntilExpiry(product.expiryDate);
    final isExpired = date_utils.DateUtils.isExpired(product.expiryDate);
    const spacing = 10.0;

    return Column(
      spacing: spacing,
      children: [
        Row(
          spacing: 10,
          children: [
            BaseProductInfoCard(
              icon: Icons.attach_money,
              label: 'السعر',
              value: product.price.toString(),
              detailsType: ProductDetailsType.price,
            ),
            BaseProductInfoCard(
              icon: Icons.inventory_2,
              label: 'الكمية',
              value: product.quantity.toString(),
              detailsType: ProductDetailsType.quantity,

            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            ProductInfoCard(
              icon: Icons.category,
              label: 'الفئة',
              value: product.category.label,
              detailsType: ProductDetailsType.category,

            ),
            ProductInfoCard(
              icon: Icons.qr_code,
              label: 'كود المنتج',
              value: product.barcode == null ? '-' : product.barcode!,
              detailsType: ProductDetailsType.barcode,
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            ProductInfoCard(
              icon: Icons.calendar_today,
              label: 'تاريخ الانتهاء',
              value: DateFormat('yyyy-MM-dd').format(product.expiryDate),
              detailsType: ProductDetailsType.expiryDate,
            
            ),

            ProductInfoCard(
              icon: Icons.schedule,
              label: 'المدة المتبقية',
              value: isExpired ? 'منتهي' : remainingTime,
              detailsType: ProductDetailsType.expiryDate,

            ),
          ],
        ),
        if (product.notes?.isNotEmpty == true)
          ProductInfoCard(
            icon: Icons.note,
            label: 'ملاحظات',
            value: product.notes!,
            detailsType: ProductDetailsType.notes,
          ),
      ],
    );
  }
}
