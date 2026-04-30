import '../../domain/entities/backup_state.dart';

enum BackupOperationType {
  backup,
  restore,
}

class BackupUiState {
  BackupUiState({
    this.backupState,
    this.isLoading = false,
    this.currentOperation,
    this.isSuccess = false,
  });

  final BackupState? backupState;
  final bool isLoading;
  final BackupOperationType? currentOperation;
  final bool isSuccess;

  BackupUiState copyWith({
    BackupState? backupState,
    bool? isLoading,
    bool? isSuccess,
    BackupOperationType? currentOperation,
  }) {
    return BackupUiState(
      backupState: backupState ?? this.backupState,
      isLoading: isLoading ?? this.isLoading,
      currentOperation: currentOperation ?? this.currentOperation,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
