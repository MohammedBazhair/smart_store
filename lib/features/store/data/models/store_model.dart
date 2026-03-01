import '../../../../core/constants/enums.dart';
import '../../domain/entities/store.dart';

class StoreModel extends Store {
  StoreModel({
    super.id,
    required super.ownerId,
    required super.name,
    required super.currency,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoreModel.fromEntity(Store store) {
    return StoreModel(
      id: store.id,
      ownerId: store.ownerId,
      name: store.name,
      currency: store.currency,
      createdAt: store.createdAt,
      updatedAt: store.updatedAt,
    );
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'],
      ownerId: map['owner_id'],
      name: map['store_name'],
      currency: Currency.values.byName(map['currency']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'owner_id': ownerId,
      'store_name': name,
      'currency': currency.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
