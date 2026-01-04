import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Alert extends Equatable {
  const Alert({
    this.id,
    required this.productId,
    required this.daysBeforeExpiry,
    required this.importance,
    required this.isRead,
    required this.createdAt,
    required this.productName,
    required this.expiryDate,
  });
  final int? id;
  final int productId;
  final String productName;
  final int daysBeforeExpiry;
  final Priority importance;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? expiryDate;

  @override
  List<Object?> get props => [
        id,
        productId,
        daysBeforeExpiry,
        importance,
        isRead,
        createdAt,
      ];
}
