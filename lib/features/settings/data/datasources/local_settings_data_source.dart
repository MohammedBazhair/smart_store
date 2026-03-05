import '../../../../core/constants/log.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../models/exchange_rate_model.dart';
import '../models/settings_model.dart';

abstract class LocalSettingsDataSource {
  Future<List<ExchangeRateModel>> getExchangeRates();
  Future<void> setExchangeRates(List<ExchangeRateModel> exchangeRates);
  Future<void> setSettings(SettingsModel settings);
}

class LocalSettingsDataSourceImpl implements LocalSettingsDataSource {
  LocalSettingsDataSourceImpl(this._localDatabase, this._cache);

  final LocalDatabaseService _localDatabase;
  final LocalCacheService _cache;

  @override
  Future<List<ExchangeRateModel>> getExchangeRates() async {
    final rows = await _localDatabase.readRows(table: 'exchange_rates');

    final exchangeRates = rows.map(ExchangeRateModel.fromMap);

    return exchangeRates.toList();
  }

  @override
  Future<void> setExchangeRates(List<ExchangeRateModel> exchangeRates) async {
    try {
      final rows = exchangeRates.map((e) => e.toMap()).toList();
      await _localDatabase.insertRows(rows: rows, table: 'exchange_rates');
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }

  @override
  Future<void> setSettings(SettingsModel settings) async {
    try {
      final json = settings.toJson();

      await _cache.setString(key: 'settings', value: json);
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }
}
