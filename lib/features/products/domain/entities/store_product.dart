// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../../core/constants/enums.dart';
import 'product.dart';
import 'sub_entities/global_product.dart';

class StoreProduct extends Product {
  const StoreProduct({
    this.id,
    required this.storeId,
    required this.globalProduct,
    required this.price,
    required this.expiryDate,
    required this.quantity,
    required this.currency,
    this.notes,
    required this.updatedAt,
  });

  factory StoreProduct.fake() {
    final date = DateTime.now();
    return StoreProduct(
      storeId: '',
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
  final String storeId;
  final GlobalProduct globalProduct;
  final num price;
  final DateTime? expiryDate;
  final int? quantity;
  final Currency currency;
  final String? notes;
  final DateTime updatedAt;

  String get quantityText => quantity?.toString() ?? 'غير محددة';

  static final fakeProducts = List.generate(8, (_) => StoreProduct.fake());

  StoreProduct copyWith({
    String? id,
    String? storeId,
    GlobalProduct? globalProduct,
    num? price,
    DateTime? expiryDate,
    int? quantity,
    Currency? currency,
    String? notes,
    DateTime? updatedAt,
  }) {
    return StoreProduct(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      globalProduct: globalProduct ?? this.globalProduct,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StoreProduct(id: $id, storeId: $storeId, globalProduct: $globalProduct, price: $price, expiryDate: $expiryDate, quantity: $quantity, currency: $currency, notes: $notes, updatedAt: $updatedAt)';
  }
}
