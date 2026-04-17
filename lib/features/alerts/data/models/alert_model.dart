import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/alert.dart';

class AlertModel extends Alert {
  const AlertModel({
    super.id,
    required super.productId,
    required super.isRead,
    required super.createdAt,
    required super.productName,
    required super.expiryDate,
    required this.daysBeforeExpiry,
    required this.importance,
  });

  factory AlertModel.fromEntity(
    Alert alert,
  ) {
    final daysBeforeExpiry =
        DateTimeUtils.daysUntilExpiry(alert.expiryDate) ?? 0;
    final importance = getPriorityFrom(daysBeforeExpiry);

    return AlertModel(
      productId: alert.productId,
      isRead: alert.isRead,
      createdAt: alert.createdAt,
      productName: alert.productName,
      expiryDate: alert.expiryDate,
      daysBeforeExpiry: daysBeforeExpiry,
      importance: importance,
    );
  }

  /// تحويل من Map إلى AlertModel
  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] as int?,
      productId: map['product_id'] as String,
      daysBeforeExpiry: map['days_before_expiry'] as int,
      importance: Priority.values.byName(map['importance'] as String),
      isRead: (map['is_read'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      expiryDate: DateTime.tryParse((map['expiry_date'] as String?) ?? ''),
      productName: map['product_name'] as String,
    );
  }

  static Priority getPriorityFrom(int daysBefore) {
    final priority = switch (daysBefore) {
      (<= 30 && >= 15) => Priority.high,
      _ => Priority.max
    };

    return priority ;
  }

  final int daysBeforeExpiry;
  final Priority importance;

  /// تحويل من AlertModel إلى Map
  Map<String, dynamic> toMap() {
    final expiryDateOnly = expiryDate?.toDateOnly.toUtc().toIso8601String();
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_name': productName,
      'expiry_date': expiryDateOnly,
      'days_before_expiry': daysBeforeExpiry,
      'importance': importance.name,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
