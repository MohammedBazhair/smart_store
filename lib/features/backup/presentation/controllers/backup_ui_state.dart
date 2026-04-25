import '../../domain/entities/backup_state.dart';

class BackupUiState {
  BackupUiState({ this.backupState, this.isLoading = false});

  final BackupState? backupState;
  final bool isLoading;

  BackupUiState copyWith({
    BackupState? backupState,
    bool? isLoading,
  }) {
    return BackupUiState(
      backupState: backupState ?? this.backupState,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
