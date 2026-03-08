import '../../../settings/domain/entities/currence_code.dart';
import '../../domain/entities/store.dart';

class StoreModel extends Store {
  StoreModel({
    super.id,
    required super.name,
    required super.currency,
    required super.createdAt,
    required super.updatedAt,
    required super.ownerPhone,
  });

  factory StoreModel.fromEntity(Store store) {
    return StoreModel(
      id: store.id,
      name: store.name,
      currency: store.currency,
      createdAt: store.createdAt,
      updatedAt: store.updatedAt,
      ownerPhone: store.ownerPhone,
    );
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'],
      ownerPhone: map['owner_phone'],
      name: map['store_name'],
      currency: CurrencyCode.values.byName(map['currency']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'owner_phone': ownerPhone,
      'store_name': name,
      'currency': currency.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
