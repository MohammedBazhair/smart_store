import '../../domain/entities/category.dart';
import '../../domain/entities/sub_entities/global_product.dart';

class GlobalProductModel extends GlobalProduct {
  GlobalProductModel({
    super.id,
    required super.category,
    required super.name,
    required super.barcode,
    required super.createdAt,
  });

  factory GlobalProductModel.fromEntity(GlobalProduct product) {
    return GlobalProductModel(
      id: product.id,
      category: product.category,
      name: product.name,
      barcode: product.barcode,
      createdAt: product.createdAt,
    );
  }

  factory GlobalProductModel.fromRemote(Map<String, dynamic> map) {
    return GlobalProductModel(
      id: map['id'] as String,
      category: Category.fromRemote(map['categories']),
      name: map['name'] as String,
      barcode: map['barcode'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  factory GlobalProductModel.fromLocal(Map<String, dynamic> map) {
    return GlobalProductModel(
      id: map['global_product_id'] as String,
      category: Category.fromLocal(map),
      name: map['product_name'] as String,
      barcode: map['barcode'] as String?,
      createdAt: DateTime.parse(map['product_created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': category.id,
      'name': name,
      'barcode': barcode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
