import '../../../settings/domain/entities/currence_code.dart';

class Store {
  Store({
     this.id,
    required this.ownerId,
    required this.name,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });
  
  final String? id;
  final String  ownerId;
  final String name;
  final CurrencyCode currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store copyWith({
    String? id,
    String? ownerId,
    String? name,
    CurrencyCode? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Store(id: $id, ownerId: $ownerId, name: $name, currency: $currency, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
