// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../../core/constants/enums.dart';
import 'product.dart';
import 'sub_entities/global_product.dart';

class SellerProduct extends Product {
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

  SellerProduct copyWith({
    String? id,
    String? sellerId,
    GlobalProduct? globalProduct,
    num? price,
    DateTime? expiryDate,
    int? quantity,
    Currency? currency,
    String? notes,
    DateTime? updatedAt,
  }) {
    return SellerProduct(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      globalProduct: globalProduct ?? this.globalProduct,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
