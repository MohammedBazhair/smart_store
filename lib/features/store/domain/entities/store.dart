import '../../../settings/domain/entities/currence_code.dart';

class Store {
  Store({
     this.id,
    required this.name,
    required this.currency,
    required this.createdAt,
    required this.updatedAt, required this.ownerPhone,
  });
  
  final String? id;
  final String ownerPhone;
  final String name;
  final CurrencyCode currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store copyWith({
    String? id,
    String? name,
  String? ownerPhone,
    CurrencyCode? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
       ownerPhone:ownerPhone?? this.ownerPhone,
    );
  }

  @override
  String toString() {
    return 'Store(id: $id, name: $name, currency: $currency, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
