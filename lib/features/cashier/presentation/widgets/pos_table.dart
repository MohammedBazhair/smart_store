import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../features/settings/domain/entities/currence_code.dart';
import '../../../../features/settings/presentation/controllers/settings_provider.dart';
import '../../domain/entities/cart_item.dart';
import 'pos_item_row.dart';

class PosTable extends ConsumerWidget {
  const PosTable({super.key, required this.cartItems});
  final List<CartItem> cartItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DataTable(
      columnSpacing: 24,
      headingRowColor: MaterialStatePropertyAll(Colors.grey.shade100),
      headingRowHeight: 30,
      dataRowHeight: 40,
      headingTextStyle:
          const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      dataTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      border: TableBorder.all(color: Colors.grey.shade200),
      horizontalMargin: 16,
      columns: const [
        DataColumn(
          columnWidth: FlexColumnWidth(1.5),
          headingRowAlignment: MainAxisAlignment.center,
          label: Text(
            'المنتج',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
        DataColumn(
          headingRowAlignment: MainAxisAlignment.center,
          columnWidth: FlexColumnWidth(),
          label: Text('الكمية'),
        ),
        DataColumn(
          headingRowAlignment: MainAxisAlignment.center,
          columnWidth: FlexColumnWidth(),
          label: Text('السعر'),
        ),
        DataColumn(
          headingRowAlignment: MainAxisAlignment.center,
          columnWidth: FlexColumnWidth(),
          label: Text(
            'الاجمالي',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
      rows: List.generate(
        cartItems.length,
        (index) {
          final item = cartItems[index];

          final unitPrice = ref
              .read(settingsControllerProvider.notifier)
              .convert(
                price: item.price, // in YER
                from: CurrencyCode.theDefault,
              )
              .price;

          final subtotal = ref
              .read(settingsControllerProvider.notifier)
              .convert(
                price: item.subtotal, // in YER
                from: CurrencyCode.theDefault,
              )
              .price;

          return DataRow(
            cells: [
              DataCell(
                Text(
                  item.product.globalProduct.name,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                QuantitySelector(item: item),
             
              ),
              DataCell(
                Text(unitPrice.formatDouble),
              ),
              DataCell(
                Text(
                  subtotal.formatDouble,
                  style: const TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }
}
