import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../products/domain/product.dart';

/// كيان التنبيه
class Alert extends Equatable {

  const Alert({
     this.id,

    required this.product,
    required this.daysBeforeExpiry,
    required this.importance,
    required this.isRead,
    required this.createdAt,
  });
  final int? id;
  final Product product;
  final int daysBeforeExpiry;
  final Priority importance; 
  final bool isRead;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        product.id,
        daysBeforeExpiry,
        importance,
        isRead,
        createdAt,
      ];
}

