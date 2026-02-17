
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

  factory GlobalProductModel.fromMap(Map<String, dynamic> map) {
    return GlobalProductModel(
      id: map['id'] as String,
      category: Category.fromMap(map['category']),
      name: map['name'] as String,
      barcode: map['barcode'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'category_id': category.id,
      'name': name,
      'barcode': barcode,
      'createdAt': createdAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
