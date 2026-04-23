import 'package:equatable/equatable.dart';
import 'expiry_reminder.dart';

class Alert extends Equatable {
  const Alert({
    this.id,
    required this.productId,
    required this.isRead,
    required this.createdAt,
    required this.productName,
    required this.expiryDate,
    required this.expiryRemainder,
  });
  final int? id;
  final String productId;
  final String productName;
  final bool isRead;
  final DateTime createdAt;
  final DateTime expiryDate;
  final ExpiryRemainder expiryRemainder;

  @override
  List<Object?> get props => [
        id,
        productId,
        isRead,
        createdAt,
        productName,
        expiryDate,
        expiryRemainder,
      ];

  @override
  bool get stringify => true;

  Alert copyWith({
    int? id,
    String? productId,
    String? productName,
    bool? isRead,
    DateTime? createdAt,
    DateTime? expiryDate,
    ExpiryRemainder? expiryRemainder,
  }) {
    return Alert(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      expiryRemainder: expiryRemainder ?? this.expiryRemainder,
    );
  }
}
