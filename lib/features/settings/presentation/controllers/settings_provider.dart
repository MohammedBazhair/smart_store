import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../data/datasources/local_settings_data_source.dart';
import '../../data/datasources/remote_settings_data_source.dart';
import '../../data/repository/settings_repository_impl.dart';
import '../../domain/entities/settings.dart';
import 'settings_controller.dart';

final remoteSettingDataSourceProvider = Provider((ref) {
  final _remoteDb = ref.read(remoteDatabaseServiceProvider);
  return RemoteSettingsDataSourceImpl(_remoteDb);
});

final localSettingDataSourceProvider = Provider((ref) {
  final _localDb = ref.read(localDatabaseServiceProvider);
  final _cache = ref.read(localCacheServiceProvider);
  return LocalSettingsDataSourceImpl(_localDb,_cache);
});

final settingsRepositoryProvider = Provider((ref) {
  final _cache = ref.read(localCacheServiceProvider);
  final _remoteSettings = ref.read(remoteSettingDataSourceProvider);
  final _localSettings = ref.read(localSettingDataSourceProvider);
  final _connectivityService = ref.read(networkProvider);

  return SettingsRepositoryImpl(
    _cache,
    _remoteSettings,
    _localSettings,
    _connectivityService,
  );
});

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, Settings>(() {
  Logger.debugLog(message: 'تم بناء المزود الاعدادات بنجاح');
  return SettingsController();
});
