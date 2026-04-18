import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ExpiryRemainder {
  ExpiryRemainder({required this.daysBeforeExpiry, required this.importance});

  factory ExpiryRemainder.fromMap(Map<String, dynamic> map) {
    return ExpiryRemainder(
      daysBeforeExpiry: map['days_before_expiry'] as int,
      importance: Priority.values.byName(map['importance'] as String),
    );
  }
  final int daysBeforeExpiry;
  final Priority importance;

  Map<String, dynamic> toMap() {
    return {
      'days_before_expiry': daysBeforeExpiry,
      'importance': importance.name,
    };
  }

  ExpiryRemainder copyWith({
    int? daysBefore,
    Priority? importance,
  }) {
    return ExpiryRemainder(
      daysBeforeExpiry: daysBefore ?? daysBeforeExpiry,
      importance: importance ?? this.importance,
    );
  }
}
