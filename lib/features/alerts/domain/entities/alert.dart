import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/utils/date_utils.dart';

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
  final String productId;
  final String productName;
  final int daysBeforeExpiry;
  final Priority importance;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? expiryDate;

  int get remainingDays => DateTimeUtils.daysUntilExpiry(expiryDate)??0;

  @override
  List<Object?> get props => [
        id,
        productId,
        daysBeforeExpiry,
        importance,
        isRead,
        createdAt,
        productName,
        expiryDate,
      ];

  @override
  bool get stringify => true;

  Alert copyWith({
    int? id,
    String? productId,
    String? productName,
    int? daysBeforeExpiry,
    Priority? importance,
    bool? isRead,
    DateTime? createdAt,
    DateTime? expiryDate,
  }) {
    return Alert(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      daysBeforeExpiry: daysBeforeExpiry ?? this.daysBeforeExpiry,
      importance: importance ?? this.importance,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
