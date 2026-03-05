import '../../../../core/constants/log.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repository/settings_repository.dart';
import '../datasources/local_settings_data_source.dart';
import '../datasources/remote_settings_data_source.dart';
import '../models/settings_model.dart';

/// تنفيذ مستودع الإعدادات
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(
    this._cache,
    this._remoteSettings,
    this._localSettings,
    this._connectivityService,
  );
  final ConnectivityService _connectivityService;
  final RemoteSettingsDataSource _remoteSettings;
  final LocalSettingsDataSource _localSettings;

  final LocalCacheService _cache;

  @override
  Future<Settings> getSettings() async {
    final raw = _cache.getString(key: 'settings');

    final exchangeRates = await getExchangeRates();

    if (raw == null) {
      return Settings.theDefault(exchangeRates);
    }

    return SettingsModel.fromJson(raw, exchangeRates);
  }

  @override
  Future<Result<void>> updateSettings(Settings settings) async {
    try {
      await setSettings(settings);
      return const SuccessState(null);
    } catch (e) {
      return const ErrorState('فشل في تحديث الإعدادات: ');
    }
  }

  @override
  Future<List<ExchangeRate>> getExchangeRates() async {
    try {
      if (await _connectivityService.hasConnection()) {
        final exchangeRates = await _remoteSettings.getExchangeRates();
        await _localSettings.setExchangeRates(exchangeRates);
        return exchangeRates;
      }

      return _localSettings.getExchangeRates();
    } catch (e) {
      Logger.debugLog(error: e);
      return _localSettings.getExchangeRates();
    }
  }

  @override
  Future<void> setSettings(Settings settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);

      await _cache.setString(key: 'settings', value: model.toJson());
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }
}
