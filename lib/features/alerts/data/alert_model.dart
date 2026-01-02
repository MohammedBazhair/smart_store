import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../products/data/product_model.dart';
import '../domain/alert.dart';

/// نموذج التنبيه للتعامل مع قاعدة البيانات
class AlertModel extends Alert {
  const AlertModel({
    required super.id,
    required super.product,
    required super.daysBeforeExpiry,
    required super.importance,
    required super.isRead,
    required super.createdAt,
  });

  /// تحويل من Entity إلى Model
  factory AlertModel.fromEntity(Alert alert) {
    return AlertModel(
      id: alert.id,
      product: alert.product,
      daysBeforeExpiry: alert.daysBeforeExpiry,
      importance: alert.importance,
      isRead: alert.isRead,
      createdAt: alert.createdAt,
    );
  }

  /// تحويل من Map إلى AlertModel
  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] as int?,
      product:ProductModel.fromMap( map['product'] as Map<String,dynamic>),
      daysBeforeExpiry: map['days_before_expiry'] as int,
      importance:Priority.values.byName(map['importance'] as String) ,
      isRead: (map['is_read'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// تحويل من AlertModel إلى Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'product': ProductModel.fromEntity(product).toMap(),
      'days_before_expiry': daysBeforeExpiry,
      'importance': importance.name,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };

    if (id != null) map['id'] = id;

    return  map;
  }
}
