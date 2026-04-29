import '../../domain/entities/alert.dart';

class AlertsState {
  AlertsState({
    required this.allAlerts,
    required this.unreadAlerts,
  });

  factory AlertsState.empty() => AlertsState(
        allAlerts: {},
        unreadAlerts: {},
      );
  final Map<int, Alert> allAlerts;
  final Map<int, Alert> unreadAlerts;

  bool get hasReadAlert => allAlerts.length != unreadAlerts.length;

  AlertsState copyWith({
    Map<int, Alert>? allAlerts,
    Map<int, Alert>? unreadAlerts,
  }) {
    return AlertsState(
      allAlerts: allAlerts ?? this.allAlerts,
      unreadAlerts: unreadAlerts ?? this.unreadAlerts,
    );
  }
}
