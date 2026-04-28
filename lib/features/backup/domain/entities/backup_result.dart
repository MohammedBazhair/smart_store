import 'backup_state.dart';

class BackupResult {
  const BackupResult({
    required this.state,
    required this.message,
   required this.dbFilePath,
  });

  final BackupState state;
  final String message;
  final String dbFilePath;

  BackupResult copyWith({
    BackupState? state,
    String? message,
    String? dbFilePath,
  }) {
    return BackupResult(
      state: state ?? this.state,
      message: message ?? this.message,
      dbFilePath: dbFilePath ?? this.dbFilePath,
    );
  }
}
