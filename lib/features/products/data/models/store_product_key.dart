import 'dart:convert';

class StoreProductKey {
  StoreProductKey({
    required this.storeId,
    required this.productId,
  });

  factory StoreProductKey.fromMap(Map<String, dynamic> map) {
    return StoreProductKey(
      storeId: map['store_id'] as String,
      productId: map['product_id'] as String,
    );
  }

  factory StoreProductKey.fromJson(String json) {
    final map = jsonDecode(json);

    return StoreProductKey.fromMap(map);
  }

  final String storeId;
  final String productId;

  Map<String, Object> toMap() {
    return {
      'store_id': storeId,
      'product_id': productId,
    };
  }

  String toJson() => jsonEncode(toMap());
}
