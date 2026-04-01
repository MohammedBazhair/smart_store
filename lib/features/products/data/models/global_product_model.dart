import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/sub_entities/global_product.dart';

class GlobalProductModel extends GlobalProduct {
  GlobalProductModel({
    super.id,
    required super.category,
    required super.name,
    required super.barcode,
    required super.createdAt,
    required super.updatedAt,
    super.isDeleted,
  });

  factory GlobalProductModel.fromEntity(GlobalProduct product) {
    return GlobalProductModel(
      id: product.id,
      category: product.category,
      name: product.name,
      barcode: product.barcode,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      isDeleted: product.isDeleted,
    );
  }

  factory GlobalProductModel.fromRemote(Map<String, dynamic> map) {
    return GlobalProductModel(
      id: map['id'] as String,
      category: Category.fromRemote(map['categories']),
      name: map['name'] as String,
      barcode: map['barcode'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isDeleted: map['is_deleted'] == 1,
    );
  }

  factory GlobalProductModel.fromLocal(Map<String, dynamic> map) {
    return GlobalProductModel(
      id: map['global_product_id']?.toString() ?? '',
      category: Category.fromLocal(map),
      name: map['product_name']?.toString() ?? 'منتج غير معروف',
      barcode: map['barcode']?.toString(),
      createdAt: DateTime.tryParse(map['product_created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['product_updated_at']?.toString() ?? '') ?? DateTime.now(),
      isDeleted: map['product_is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': category.id,
      'name': name,
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted.toInt,
    };
  }
}
