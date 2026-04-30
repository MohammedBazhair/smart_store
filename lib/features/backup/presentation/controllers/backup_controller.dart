import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../core/shared/providers/ui_providers.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/backup_result.dart';
import '../../domain/entities/backup_state.dart';
import '../../domain/repositories/backup_repository.dart';
import 'backup_providers.dart';
import 'backup_ui_state.dart';
import 'progress_controller.dart';

class BackupController extends Notifier<BackupUiState> {
  LocalCacheService get _cacheService => ref.read(localCacheServiceProvider);
  BackupRepository get _backupRepository => ref.read(backupRepositoryProvider);
  ProgressController get _progressController =>
      ref.read(progressControllerProvider.notifier);
  AppUiEventController get _uiController =>
      ref.read(appUiEventProvider.notifier);

  final _keyBackup = 'db_backup';

  @override
  BackupUiState build() {
    final source = _cacheService.getString(key: _keyBackup);
    if (source == null) return BackupUiState();

    final backupState = BackupState.fromJson(source);

    return BackupUiState(backupState: backupState);
  }

  Future<void> createBackup() async {
    state = state.copyWith(
      isLoading: true,
      currentOperation: BackupOperationType.backup,
    );

    final selectedType = ref.read(backupTypeProvider);

    _progressController.setStage('جاري التجهيز...');

    final result = await _backupRepository.createBackup(
      selectedType,
      _progressController.update,
    );

    return _emitState(result);
  }

  Future<void> restoreBackup() async {
    state = state.copyWith(
      isLoading: true,
      currentOperation: BackupOperationType.restore,
    );

    final selectedType = ref.read(restoreSourceProvider);
    _progressController.setStage('جاري الرفع...');

    final result = await _backupRepository.restoreBackup(
      selectedType,
      _progressController.update,
    );

    return _emitState(result);
  }

  Future<void> _emitState(Result<BackupResult> result) async {
    switch (result) {
      case SuccessState<BackupResult>(:final data):
        state = state.copyWith(
          backupState: data.state,
          isLoading: false,
          isSuccess: true,
        );
        _uiController.showSuccess(data.message);
        // ignore: unawaited_futures
        _cacheService.setString(
          key: _keyBackup,
          value: state.backupState!.toJson(),
        );

      case ErrorState<BackupResult>(:final message):
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
        );
        _uiController.showError(message);
    }
  }
}
