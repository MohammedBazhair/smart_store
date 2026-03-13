import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/shared/data/models/sync_change_model.dart';
import '../../../../core/shared/datasources/sync_local_data_source.dart';
import '../../domain/entities/currence_code.dart';
import '../models/exchange_rate_model.dart';
import '../models/settings_model.dart';

abstract class LocalSettingsDataSource {
  Future<List<ExchangeRateModel>> getExchangeRates();

  Future<void> setExchangeRates(List<ExchangeRateModel> exchangeRates);

  Future<void> setSettings(SettingsModel settings);

  Future<void> changeDefaultCurrency({
    required CurrencyCode currency,
    required String storeId,
    bool skipLocalTracking = false,
  });
}

class LocalSettingsDataSourceImpl implements LocalSettingsDataSource {
  LocalSettingsDataSourceImpl(this._localDatabase, this._cache, this._sync);

  final LocalDatabaseService _localDatabase;
  final LocalCacheService _cache;
  final SyncLocalDataSource _sync;

  @override
  Future<List<ExchangeRateModel>> getExchangeRates() async {
    final rows = await _localDatabase.readRows(table: 'exchange_rates');

    final exchangeRates = rows.map(ExchangeRateModel.fromMap);

    return exchangeRates.toList();
  }

  @override
  Future<void> setExchangeRates(List<ExchangeRateModel> exchangeRates) async {
    if (exchangeRates.isEmpty) return;
    try {
      final rows = exchangeRates.map((e) => e.toMap()).toList();
      await _localDatabase.insertRows(
        rows: rows,
        table: 'exchange_rates',
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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

  @override
  Future<void> changeDefaultCurrency({
    required CurrencyCode currency,
    required String storeId,
    bool skipLocalTracking = false,
  }) async {
    await _localDatabase.update(
      updated: {
        'currency': currency.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      filterWhere: {'id': storeId},
      table: 'stores',
    );

    if (skipLocalTracking) return;
    final change = SyncChangeModel(
      tableName: 'stores',
      recordId: storeId,
      operation: SyncOperation.update,
      updatedAt: DateTime.now().toUtc(),
    );
    await _sync.addChange(change);
  }
}
