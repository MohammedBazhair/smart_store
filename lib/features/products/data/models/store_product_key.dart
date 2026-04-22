import 'dart:convert';

import '../../../../core/database/local/query_where_builder.dart';

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

  WhereQueryParams getWhereParams() {
    return WhereQueryParams(
      groups: [
        FilterGroup(
          filters: [
            Filter(
              column: 'product_id',
              value: productId,
            ),
            Filter(
              column: 'store_id',
              value: storeId,
            ),
          ],
        ),
      ],
    );
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
