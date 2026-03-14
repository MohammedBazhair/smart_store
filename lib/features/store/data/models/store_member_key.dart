import 'dart:convert';

import 'package:equatable/equatable.dart';

class StoreMemberKey extends Equatable {
  const StoreMemberKey({
    required this.storeId,
    required this.memberPhone,
  });

  /// إنشاء الكائن من Map
  factory StoreMemberKey.fromMap(Map<String, dynamic> map) {
    return StoreMemberKey(
      storeId: map['store_id'] as String,
      memberPhone: map['member_phone'] as String,
    );
  }

  /// إنشاء من JSON
  factory StoreMemberKey.fromJson(String json) {
    final map = jsonDecode(json);

    return StoreMemberKey.fromMap(map);
  }

  final String storeId;
  final String memberPhone;

  /// تحويل إلى Map (مفيد لـ SQLite و Supabase)
  Map<String, Object> toMap() {
    return {
      'store_id': storeId,
      'member_phone': memberPhone,
    };
  }

  /// تحويل إلى JSON
  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [storeId, memberPhone];
}
