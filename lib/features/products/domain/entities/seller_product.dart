import 'package:equatable/equatable.dart';

import '../../../../core/constants/enums.dart';
import 'sub_entities/global_product.dart';

class SellerProduct extends Equatable {
  const SellerProduct({
    this.id,
    required this.sellerId,
    required this.globalProduct,
    required this.price,
    required this.expiryDate,
    required this.quantity,
    required this.currency,
    this.notes,
    required this.updatedAt,
  });

  factory SellerProduct.fake() {
    final date = DateTime.now();
    return SellerProduct(
      sellerId: '',
      globalProduct: GlobalProduct.fake(),
      quantity: 50,
      expiryDate: date,
      notes: 'mhjhjh',
      updatedAt: date,
      currency: Currency.YER,
      price: 1500,
    );
  }

  final String? id;
  final String sellerId;
  final GlobalProduct globalProduct;
  final num price;
  final DateTime? expiryDate;
  final int? quantity;
  final Currency currency;
  final String? notes;
  final DateTime updatedAt;

  String get quantityText => quantity?.toString() ?? 'غير محددة';

  static final fakeProducts = List.generate(8, (_) => SellerProduct.fake());

  @override
  List<Object?> get props => [
        id,
        sellerId,
        globalProduct.id,
      ];
}
