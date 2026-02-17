import '../category.dart';

class GlobalProduct {
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
      createdAt: DateTime.now(),
    );
  }

  final String? id;
  final Category category;
  final String name;
  final String? barcode;
  final DateTime createdAt;
}
