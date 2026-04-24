import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../core/shared/providers/ui_providers.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/backup_result.dart';
import '../../domain/entities/backup_state.dart';
import '../../domain/repositories/backup_repository.dart';
import 'backup_providers.dart';

class BackupController extends Notifier<BackupState?> {
  LocalCacheService get _cacheService => ref.read(localCacheServiceProvider);
  BackupRepository get _backupRepository => ref.read(backupRepositoryProvider);

  final _keyBackup = 'db_backup';

  @override
  BackupState? build() {
    final source = _cacheService.getString(key: _keyBackup);
    if (source == null) return null;

    return BackupState.fromJson(source);
  }

  Future<Result<String>> createBackup() async {
    final loading = ref.read(isLoadingProvider(IsLoading.backup).notifier);
    loading.state = true;

    final selectedType = ref.read(backupTypeProvider);

    final result = await _backupRepository.createBackup(selectedType);
    loading.state = false;

    return _emitState(result);
  }

  Future<Result<String>> restoreBackup() async {
    final loading = ref.read(isLoadingProvider(IsLoading.backup).notifier);
    loading.state = true;
    final selectedType = ref.read(restoreSourceProvider);

    final result = await _backupRepository.restoreBackup(selectedType);
    loading.state = false;

    return _emitState(result);
  }

  Future<Result<String>> _emitState(Result<BackupResult> result) async {
    switch (result) {
      case SuccessState<BackupResult>(:final data):
        state = data.state;
        // ignore: unawaited_futures
        _cacheService.setString(key: _keyBackup, value: state!.toJson());

        return SuccessState(data.message);
      case ErrorState<BackupResult>(:final message):
        return ErrorState(message);
    }
  }
}
