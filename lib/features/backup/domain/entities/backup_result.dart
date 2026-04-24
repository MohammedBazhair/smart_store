import 'backup_state.dart';

class BackupResult {
  const BackupResult({
    required this.state,
    required this.message,
  });

  final BackupState state;
  final String message;

  BackupResult copyWith({
    BackupState? state,
    String? message,
  }) {
    return BackupResult(
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }
}
