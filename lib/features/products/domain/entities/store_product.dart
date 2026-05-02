import 'product.dart';
import 'sub_entities/global_product.dart';

class StoreProduct extends Product {
  const StoreProduct({
    required this.storeId,
    required this.globalProduct,
    required this.price,
    required this.expiryDate,
    required this.quantity,
    required this.notes,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory StoreProduct.fake() {
    final date = DateTime.now().add(const Duration(days: 300)).toUtc();
    return StoreProduct(
      storeId: '',
      globalProduct: GlobalProduct.fake(),
      quantity: 50,
      expiryDate: date,
      notes: 'mhjhjh',
      updatedAt: date,
      price: 1500,
    );
  }

  final String storeId;
  final GlobalProduct globalProduct;
  final num price;
  final DateTime? expiryDate;
  final int? quantity;
  final String notes;
  final DateTime updatedAt;
  final bool isDeleted;

  String get quantityText => quantity?.toString() ?? 'غير محددة';
  String? get id => globalProduct.id;
  
  /// return true if barcode not null and not empty.
  bool get  hasBarcode => globalProduct.barcode?.isNotEmpty??false;

  static final fakeProducts = List.generate(8, (_) => StoreProduct.fake());

  StoreProduct copyWith({
    String? storeId,
    GlobalProduct? globalProduct,
    num? price,
    DateTime? expiryDate,
    int? quantity,
    String? notes,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return StoreProduct(
      storeId: storeId ?? this.storeId,
      globalProduct: globalProduct ?? this.globalProduct,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'StoreProduct(storeId: $storeId, globalProduct: $globalProduct, price: $price, expiryDate: $expiryDate, quantity: $quantity, notes: $notes, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }
}
