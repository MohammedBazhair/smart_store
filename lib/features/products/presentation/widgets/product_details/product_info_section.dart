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
        date_utils.DateTimeUtils.timeUntilExpiry(product.expiryDate);
    final isExpired = date_utils.DateTimeUtils.isExpired(product.expiryDate);
    const spacing = 10.0;

    return Column(
      spacing: spacing,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: BaseProductInfoCard(
                icon: Icons.attach_money,
                label: 'السعر',
                value: product.price.toString(),
                detailsType: ProductDetailsType.price,
                iconColor: const Color(0xFF0FA4AF),
              ),
            ),
            Expanded(
              child: BaseProductInfoCard(
                icon: Icons.inventory_2,
                label: 'الكمية',
                value: product.quantityText,
                detailsType: ProductDetailsType.quantity,
                iconColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: ProductInfoCard(
                icon: Icons.category,
                label: 'الفئة',
                value: product.category.label,
                detailsType: ProductDetailsType.category,
                iconColor: const Color(0xFF0FA4AF),
              ),
            ),
            Expanded(
              child: ProductInfoCard(
                icon: Icons.qr_code,
                label: 'كود المنتج',
                value: product.barcode == null ? '-' : product.barcode!,
                detailsType: ProductDetailsType.barcode,
                iconColor: const Color(0xFF6669F1),
              ),
            ),
          ],
        ),
        if (remainingTime != null && isExpired != null)
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: ProductInfoCard(
                  icon: Icons.calendar_today,
                  label: 'تاريخ الانتهاء',
                  value: DateFormat('yyyy-MM-dd').format(product.expiryDate!),
                  detailsType: ProductDetailsType.expiryDate,
                  iconColor: const Color(0xFFF97316),
                ),
              ),
              Expanded(
                child: ProductInfoCard(
                  icon: Icons.schedule,
                  label: 'المدة المتبقية',
                  value: isExpired ? 'منتهي' : remainingTime,
                  detailsType: ProductDetailsType.expiryDate,
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        if (product.notes?.isNotEmpty == true)
          ProductInfoCard(
            icon: Icons.note,
            label: 'ملاحظات',
            value: product.notes!,
            detailsType: ProductDetailsType.notes,
            iconColor: const Color(0xFF9CA3AF),
          ),
      ],
    );
  }
}
