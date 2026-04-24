import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/database/local/database_helper.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../data/datasources/local_backup_datasource_impl.dart';
import '../../data/datasources/remote_backup_datasource_impl.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../domain/entities/backup_state.dart';
import '../../domain/repositories/backup_repository.dart';
import 'backup_controller.dart';

final localBackupDatasourceProvider = Provider((ref) {
  final _dbHelper = DatabaseHelper.instance;
  return LocalBackupDatasourceImpl(_dbHelper);
});

final remoteBackupDatasourceProvider = Provider((ref) {
  final _remoteStorage = ref.read(remoteStorageServiceProvider);
  final userPhone =
      ref.watch(userControllerProvider).entity.profile.phone ?? '-';
  final _networkClient = ref.read(networkCilientProvider);
  final _dbHelper = DatabaseHelper.instance;
  return RemoteBackupDatasourceImpl(
    _remoteStorage,
    userPhone,
    _networkClient,
    _dbHelper,
  );
});

/// Provider لمستودع النسخ الاحتياطي
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final localDb = ref.read(localBackupDatasourceProvider);
  final remoteDb = ref.read(remoteBackupDatasourceProvider);
  final connectivityService= ref.read(networkProvider);
  return BackupRepositoryImpl(localDb, remoteDb,connectivityService);
});

final backupControllerProvider =
    NotifierProvider<BackupController, BackupState?>(() {
  return BackupController();
});

final backupTypeProvider =
    StateProvider.autoDispose<BackupType>((ref) => BackupType.hybrid);
    
final restoreSourceProvider =
    StateProvider.autoDispose<BackupType>((ref) => BackupType.local);
