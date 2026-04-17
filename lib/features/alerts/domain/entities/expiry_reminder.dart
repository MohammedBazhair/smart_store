import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ExpiryReminder {
  ExpiryReminder({required this.daysBefore, required this.importance});
  final int daysBefore;
  final Priority importance;
}
