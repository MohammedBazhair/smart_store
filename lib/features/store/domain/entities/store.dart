import '../../../settings/domain/entities/currence_code.dart';
import '../../presentation/controller/store_state.dart';

class Store {
  const Store({
    this.id,
    required this.name,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerPhone,
    required this.isDeleted,
  });

  factory Store.empty() {
    return Store(
      name: 'name',
      currency: CurrencyCode.YER,
      createdAt: DateTime.timestamp(),
      updatedAt: DateTime.timestamp(),
      ownerPhone: '771234567',
      isDeleted: false,
    );
  }

  final String? id;
  final String ownerPhone;
  final String name;
  final CurrencyCode currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  static List<Store> get fakeStoresList =>
      List.generate(5, (_) => Store.empty());

  static List<StoreWithMembers> get fakeStoresWithMembersList => List.generate(
        5,
        (_) => StoreWithMembers(store: Store.empty(), members: {}),
      );

  Store copyWith({
    String? id,
    String? name,
    String? ownerPhone,
    CurrencyCode? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Store(id: $id, name: $name, currency: $currency, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
