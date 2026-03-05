import '../../../../core/database/remote/remote_database_service.dart';
import '../models/exchange_rate_model.dart';

abstract class RemoteSettingsDataSource {
  Future<List<ExchangeRateModel>> getExchangeRates();
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
}
