import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/background_utils.dart';
import '../../../../errors/result.dart';
import '../../domain/datasources/local_backup_datasource.dart';
import '../../domain/datasources/remote_backup_datasource.dart';
import '../../domain/entities/backup_result.dart';
import '../../domain/entities/backup_type.dart';
import '../../domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(
    this._localBackup,
    this._remoteBackup,
    this._connectivityService,
  );

  final LocalBackupDatasource _localBackup;
  final RemoteBackupDatasource _remoteBackup;
  final ConnectivityService _connectivityService;

  @override
  Future<Result<BackupResult>> createBackup(BackupType backupType) async {
    final hasConnection = await _connectivityService.hasConnection();
    if (!hasConnection) return const ErrorState('يجب الاتصال بالانترنت');

    await BackgroundUtils().syncAllData();

    Result<BackupResult> result;

    switch (backupType) {
      case BackupType.local:
        result = await _localBackup.backupDb();

      case BackupType.cloud:
        result = await _remoteBackup.backupDb();

      case BackupType.hybrid:
        final localState = await _localBackup.backupDb();

        if (localState case SuccessState<BackupResult>()) {
          result = await _remoteBackup.backupDb();
        } else {
          result = localState;
        }
    }

    switch (result) {
      case SuccessState<BackupResult>(:final data):
        if (backupType != BackupType.hybrid) return result;
        final newState = data.state.copyWith(type: BackupType.hybrid);

        return SuccessState(data.copyWith(state: newState));

      case ErrorState<BackupResult>():
        return result;
    }
  }

  @override
  Future<Result<BackupResult>> restoreBackup(RestoreBackupType source)  {
    switch (source) {
      case RestoreBackupType.local:
        return _localBackup.restoreDb();
      case RestoreBackupType.cloud:
        return _remoteBackup.restoreDb();
    }
  }
}
