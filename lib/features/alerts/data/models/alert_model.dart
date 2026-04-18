import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/alert.dart';
import '../../domain/entities/expiry_reminder.dart';

class AlertModel extends Alert {
  const AlertModel({
    super.id,
    required super.productId,
    required super.isRead,
    required super.createdAt,
    required super.productName,
    required super.expiryDate,
    required super.expiryRemainder,
  });

  factory AlertModel.fromEntity(
    Alert alert,
  ) {
    return AlertModel(
      productId: alert.productId,
      isRead: alert.isRead,
      createdAt: alert.createdAt,
      productName: alert.productName,
      expiryDate: alert.expiryDate,
      expiryRemainder: alert.expiryRemainder,
    );
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] as int?,
      productId: map['product_id'] as String,
      isRead: (map['is_read'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      expiryDate: DateTime.parse((map['expiry_date'] as String)),
      productName: map['product_name'] as String,
      expiryRemainder: ExpiryRemainder.fromMap(map),
    );
  }

  Map<String, dynamic> toMap() {
    final expiryDateOnly = expiryDate.toUtcDateOnly.toIso8601String();
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_name': productName,
      'expiry_date': expiryDateOnly,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      ...expiryRemainder.toMap(),
    };
  }
}
