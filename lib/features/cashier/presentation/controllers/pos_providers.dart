import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/typedef.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../printinig_share/entities/invoice.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/entities/quantity_selection_item.dart';
import '../widgets/dialogs/manage_quick_products_dialog.dart';
import 'pos_controller.dart';
import 'pos_state.dart';
import 'quick_products_controller.dart';

final quantitySelectionProvider =
    StateProvider((ref) => QuantitySelectionItem());

final posControllerProvider = NotifierProvider<PosController, PosState>(() {
  return PosController();
});

final invoiceProvider = Provider.autoDispose<Invoice>((ref) {
  final posState = ref.watch(posControllerProvider);
  final storeName =
      ref.watch(storeControllerProvider).state.selectedStore?.store.name ??
          'متجر غير معروف';

  final now = DateTime.now();
  final invoiceId = 'INV-${now.millisecondsSinceEpoch.toString().substring(5)}';

  return Invoice(
    storeName: storeName,
    invoiceNumber: invoiceId,
    date: now.formattedDate,
    time: now.formattedTime,
    subTotal: posState.totalPrice.formatDouble,
    taxAmount: '0.00',
    discount: '0.00',
    total: posState.totalPrice.formatDouble,
    finalTotal: posState.totalPrice.formatDouble,
    items: posState.cartItems.values.map((item) {
      return InvoiceItem(
        name: item.product.globalProduct.name,
        quantity: item.quantity.toString(),
        unitPrice: item.price.formatDouble,
        total: (item.quantity * item.price).formatDouble,
      );
    }),
  );
});

final quickProductsProvider =
    NotifierProvider<QuickProductsController, ProductsByIdentifier>(() {
  return QuickProductsController();
});

final quickTabProvider = StateProvider((ref)=> QuickTabType.onlyQuick);
