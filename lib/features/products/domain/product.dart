import 'package:equatable/equatable.dart';
import '../../../core/constants/enums.dart';

class Product extends Equatable {
  const Product({
    this.id,
    required this.name,
    required this.quantity,
    this.barcode,
    required this.expiryDate,
    required this.category,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    required this.currency,
  });

  factory Product.fake() {
    final date = DateTime.now().add(const Duration(days: 50000));
    return Product(
      name: 'new_product',
      quantity: 50,
      barcode: '87861',
      expiryDate: date,
      category: ProductCategory.others,
      notes: 'mhjhjh',
      createdAt: date,
      updatedAt: date,
      id: 1,
      currency: Currency.YER,
      price: 1500,
    );
  }

  final int? id;
  final String name;
  final int? quantity;
  final String? barcode;
  final DateTime? expiryDate;
  final ProductCategory category;
  final double price;
  final Currency currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get quantityText => quantity?.toString() ?? 'غير محددة';

static final fakeProducts = List.generate(8, (_) => Product.fake());


  @override
  List<Object?> get props => [
        id,
        name,
        quantity,
        barcode,
        expiryDate,
        category,
        notes,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;

  Product copyWith({
    int? id,
    String? name,
    int? quantity,
    String? barcode,
    DateTime? expiryDate,
    ProductCategory? category,
    double? price,
    Currency? currency,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      barcode: barcode ?? this.barcode,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
