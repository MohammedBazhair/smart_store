import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../settings/domain/entities/currence_code.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';
import '../../../domain/entities/product_details.dart';
import '../../../domain/entities/store_product.dart';
import 'product_info_card.dart';

class ProductInfoSection extends ConsumerWidget {
  const ProductInfoSection({super.key, required this.product});
  final StoreProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingTimeFormatted =
        date_utils.DateTimeUtils.timeUntilExpiry(product.expiryDate);
    final isExpired = date_utils.DateTimeUtils.isExpired(product.expiryDate);
    const spacing = 10.0;

    final (:price, :currency) =
        ref.read(settingsControllerProvider.notifier).convert(
              from: CurrencyCode.theDefault,
              price: product.price,
            );

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
                value: price.formatDouble,
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
                value: product.globalProduct.category.name,
                detailsType: ProductDetailsType.category,
                iconColor: const Color(0xFF0FA4AF),
              ),
            ),
            Expanded(
              child: ProductInfoCard(
                icon: Icons.qr_code,
                label: 'كود المنتج',
                value: product.hasBarcode
                    ? product.globalProduct.barcode!
                    : 'لا يوجد',
                detailsType: ProductDetailsType.barcode,
                iconColor: const Color(0xFF6669F1),
              ),
            ),
          ],
        ),
        if (remainingTimeFormatted != null && isExpired != null)
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: ProductInfoCard(
                  icon: Icons.calendar_today,
                  label: 'تاريخ الانتهاء',
                  value: product.expiryDate!.formattedDate,
                  detailsType: ProductDetailsType.expiryDate,
                  iconColor: const Color(0xFFF97316),
                ),
              ),
              Expanded(
                child: ProductInfoCard(
                  icon: Icons.schedule,
                  label: 'المدة المتبقية',
                  value: isExpired ? 'منتهي' : remainingTimeFormatted,
                  detailsType: ProductDetailsType.expiryDate,
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: ProductInfoCard(
                icon: Icons.paid_sharp,
                label: 'العملة',
                value: currency.label,
                detailsType: ProductDetailsType.currency,
                iconColor: const Color(0xFF0F67AF),
              ),
            ),
            Expanded(
              child: ProductInfoCard(
                icon: Icons.manage_history,
                label: 'اخر تحديث',
                value: product.updatedAt.formattedDate,
                iconColor: const Color(0xFFF166BC),
              ),
            ),
          ],
        ),
        if (product.notes.isNotEmpty)
          ProductInfoCard(
            icon: Icons.note,
            label: 'ملاحظات',
            value: product.notes,
            detailsType: ProductDetailsType.notes,
            iconColor: const Color(0xFF9CA3AF),
            subtitleMaxLines: 10,
          ),
      ],
    );
  }
}
