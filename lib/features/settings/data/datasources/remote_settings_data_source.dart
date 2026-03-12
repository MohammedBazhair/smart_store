import '../../../../core/database/remote/remote_database_service.dart';
import '../../domain/entities/currence_code.dart';
import '../models/exchange_rate_model.dart';

abstract class RemoteSettingsDataSource {
  Future<List<ExchangeRateModel>> getExchangeRates();

  Future<void> changeDefaultCurrency({
    required CurrencyCode currency,
    required String storeId,
  });
}

class RemoteSettingsDataSourceImpl implements RemoteSettingsDataSource {
  RemoteSettingsDataSourceImpl(this._remoteDatabase);

  final RemoteDatabaseService _remoteDatabase;

  @override
  Future<List<ExchangeRateModel>> getExchangeRates() async {
    final rows = await _remoteDatabase.readRows(table: 'exchange_rates');

    final exchangeRates = rows.map(ExchangeRateModel.fromMap);

    return exchangeRates.toList();
  }

  @override
  Future<void> changeDefaultCurrency({
    required CurrencyCode currency,
    required String storeId,
  }) async {
    await _remoteDatabase.update(
      updated: {
        'currency': currency.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      whereFilter: { 'id':storeId},
      table: 'stores',
    );
  }
}
