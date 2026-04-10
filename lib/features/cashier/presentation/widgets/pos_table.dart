import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../features/settings/domain/entities/currence_code.dart';
import '../../../../features/settings/presentation/controllers/settings_provider.dart';
import '../../domain/entities/cart_item.dart';
import 'dismissible_item.dart';
import 'quantity_selector.dart';

class PosTable extends ConsumerWidget {
  const PosTable({super.key, required this.cartItems});
  final List<CartItem> cartItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DataTable(
      columnSpacing: 0,
      headingRowColor: MaterialStatePropertyAll(Colors.grey.shade100),
      headingRowHeight: 30,
      dataRowHeight: 40,
      showBottomBorder: true,
      showCheckboxColumn: false,
      headingTextStyle:
          const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      dataTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      border: TableBorder.all(color: Colors.grey.shade200),
      horizontalMargin: 0,
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
                DismissibleItem(
                  item: item,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Baseline(
                      baseline: 8,
                      baselineType: TextBaseline.alphabetic,
                      child: Text(
                        item.product.globalProduct.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          letterSpacing: 0.1,
                          color: AppTheme.primaryColor,
                          fontSize: 11,
                          height: 1.3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox.expand(
                  child: QuantitySelector(item: item),
                ),
              ),
              DataCell(
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      unitPrice.formatDouble,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      subtotal.formatDouble,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }
}

