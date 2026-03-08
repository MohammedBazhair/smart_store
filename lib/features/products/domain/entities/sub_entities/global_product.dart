// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../category.dart';
import '../product.dart';

class GlobalProduct extends Product {
  GlobalProduct({
    this.id,
    required this.category,
    required this.name,
    required this.barcode,
    required this.createdAt,
  });

  factory GlobalProduct.fake() {
    return GlobalProduct(
      category: Category.undefined(),
      name: 'Fake Product',
      barcode: 'fake_barcode',
      createdAt: DateTime.now().toUtc(),
    );
  }

  final String? id;
  final Category category;
  final String name;
  final String? barcode;
  final DateTime createdAt;

  GlobalProduct copyWith({
    String? id,
    Category? category,
    String? name,
    String? barcode,
    DateTime? createdAt,
  }) {
    return GlobalProduct(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'GlobalProduct(id: $id, category: $category, name: $name, barcode: $barcode, createdAt: $createdAt)';
  }
}
