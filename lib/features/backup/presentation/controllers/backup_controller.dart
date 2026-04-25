import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/backup_result.dart';
import '../../domain/entities/backup_state.dart';
import '../../domain/repositories/backup_repository.dart';
import 'backup_providers.dart';
import 'backup_ui_state.dart';

class BackupController extends Notifier<BackupUiState> {
  LocalCacheService get _cacheService => ref.read(localCacheServiceProvider);
  BackupRepository get _backupRepository => ref.read(backupRepositoryProvider);

  final _keyBackup = 'db_backup';

  @override
  BackupUiState build() {
    final source = _cacheService.getString(key: _keyBackup);
    if (source == null) return BackupUiState();

    final backupState = BackupState.fromJson(source);

    return BackupUiState(backupState: backupState);
  }

  Future<Result<String>> createBackup() async {
    state = state.copyWith(isLoading: true);

    final selectedType = ref.read(backupTypeProvider);

    final result = await _backupRepository.createBackup(selectedType);

    return _emitState(result);
  }

  Future<Result<String>> restoreBackup() async {
    state = state.copyWith(isLoading: true);


    final selectedType = ref.read(restoreSourceProvider);

    final result = await _backupRepository.restoreBackup(selectedType);

    return _emitState(result);
  }

  Future<Result<String>> _emitState(Result<BackupResult> result) async {
    switch (result) {
      case SuccessState<BackupResult>(:final data):
        state = state.copyWith(backupState:  data.state,isLoading: false);
        // ignore: unawaited_futures
        _cacheService.setString(key: _keyBackup, value: state.backupState!.toJson());

        return SuccessState(data.message);
      case ErrorState<BackupResult>(:final message):
        return ErrorState(message);
    }
  }
}
