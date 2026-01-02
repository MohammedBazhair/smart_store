
import '../../../core/constants/enums.dart';
import '../domain/product.dart';

/// نموذج المنتج للتعامل مع قاعدة البيانات
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.quantity,
    super.barcode,
    required super.expiryDate,
    required super.category,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    required super.price,
    required super.currency,
  });

  /// تحويل من Entity إلى Model
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      quantity: product.quantity,
      barcode: product.barcode,
      expiryDate: product.expiryDate,
      category: product.category,
      notes: product.notes,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      currency: product.currency,
      price: product.price,
    );
  }

  /// تحويل من Map إلى ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as int?,
      barcode: map['barcode'] as String?,
      expiryDate: DateTime.parse(map['expiry_date'] as String),
      category: ProductCategory.values.byName(map['category'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      currency: Currency.values.byName(map['currency']),
      price: map['price'] as double,
    );
  }

  /// تحويل من ProductModel إلى Map
  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'quantity': quantity,
      'barcode': barcode,
      'expiry_date': expiryDate.toIso8601String(),
      'category': category.name,
      'price': price,
      'currency': currency.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id != null) map['id'] = id;

    return map;
  }
}
