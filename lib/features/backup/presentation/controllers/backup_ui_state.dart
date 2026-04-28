import '../../../../core/constants/enums.dart';
import '../../domain/entities/backup_state.dart';

enum BackupOperationType {
  backup,
  restore,
}

class BackupUiState {
  BackupUiState({
    this.backupState,
    this.isLoading = false,
    this.message,
    this.messageType,
    this.currentOperation,
  });

  final BackupState? backupState;
  final bool isLoading;
  final String? message;
  final SnackBarType? messageType;
  final BackupOperationType? currentOperation;

  bool get hasMessage => message != null && messageType != null;

  BackupUiState copyWith({
    BackupState? backupState,
    bool? isLoading,
    String? message,
    SnackBarType? messageType,
    BackupOperationType? currentOperation,
  }) {
    return BackupUiState(
      backupState: backupState ?? this.backupState,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      messageType: messageType,
      currentOperation: currentOperation,
    );
  }
}
