import '../../../../core/constants/enums.dart';
import '../../domain/entities/seller_product.dart';
import 'global_product_model.dart';

class SellerProductModel extends SellerProduct {
  const SellerProductModel({
    super.id,
    required super.sellerId,
    required super.quantity,
    required super.expiryDate,
    required super.updatedAt,
    required super.price,
    required super.currency,
    required super.globalProduct,
    super.notes,
  });

  /// تحويل من Entity إلى Model
  factory SellerProductModel.fromEntity(SellerProduct product) {
    return SellerProductModel(
      id: product.id,
      sellerId: product.sellerId,
      globalProduct: product.globalProduct,
      quantity: product.quantity,
      expiryDate: product.expiryDate,
      notes: product.notes,
      updatedAt: product.updatedAt,
      currency: product.currency,
      price: product.price,
    );
  }

  factory SellerProductModel.fromRemote(Map<String, dynamic> map) {
    return SellerProductModel(
      id: map['id'] as String?,
      sellerId: map['seller_id'] as String,
      globalProduct: GlobalProductModel.fromRemote(map['global_products']),
      quantity: map['quantity'] as int?,
      expiryDate: DateTime.tryParse((map['expiry_date'] as String?) ?? ''),
      notes: map['notes'] as String?,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      currency: Currency.values.byName(map['currency']),
      price: map['price'] as num,
    );
  }

  factory SellerProductModel.fromLocal(Map<String, dynamic> map) {
    return SellerProductModel(
      id: map['seller_product_id'],
      sellerId: map['seller_id'],
      price: map['price'] as num,
      quantity: map['quantity'],
      currency: Currency.values.byName(map['currency']),
      expiryDate: DateTime.tryParse(map['expiry_date']),
      notes: map['notes'],
      globalProduct: GlobalProductModel.fromLocal(map),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'quantity': quantity,
      'expiry_date': expiryDate?.toIso8601String(),
      'price': price,
      'currency': currency.name,
      'notes': notes,
      'updated_at': updatedAt.toIso8601String(),
      'seller_id': sellerId,
      'product_id': globalProduct.id,
    };

    if (id != null) map['id'] = id;

    return map;
  }

  
}
