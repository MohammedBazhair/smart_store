import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/store_product.dart';
import 'global_product_model.dart';

class StoreProductModel extends StoreProduct {
  const StoreProductModel({
    required super.storeId,
    required super.quantity,
    required super.expiryDate,
    required super.updatedAt,
    required super.price,
    required super.globalProduct,
   required super.notes,
    super.isDeleted,
  });

  factory StoreProductModel.fromEntity(StoreProduct product) {
    return StoreProductModel(
      storeId: product.storeId,
      globalProduct: product.globalProduct,
      quantity: product.quantity,
      expiryDate: product.expiryDate,
      notes: product.notes,
      updatedAt: product.updatedAt,
      price: product.price,
      isDeleted: product.isDeleted,
    );
  }

  factory StoreProductModel.fromRemote(Map<String, dynamic> map) {
    return StoreProductModel(
      storeId: map['store_id'] as String,
      globalProduct: GlobalProductModel.fromRemote(map['global_products']),
      quantity: map['quantity'] as int?,
      expiryDate: DateTime.tryParse((map['expiry_date'] as String?) ?? ''),
      notes: map['notes'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      price: map['price'] as num,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  factory StoreProductModel.fromLocal(Map<String, dynamic> map) {
    return StoreProductModel(
      storeId: map['store_id']?.toString() ?? '',
      price: map['price'] as num? ?? 0,
      quantity: map['quantity'] as int?,
      expiryDate: DateTime.tryParse(map['expiry_date']?.toString() ?? ''),
      notes: map['notes']?.toString() ?? '',
      globalProduct: GlobalProductModel.fromLocal(map),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store_id': storeId,
      'product_id': globalProduct.id,
      'price': price,
      'expiry_date': expiryDate?.toIso8601String(),
      'quantity': quantity,
      'notes': notes,
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted.toInt,
    };
  }
}
