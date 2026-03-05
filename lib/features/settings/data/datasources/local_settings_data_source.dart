import '../../../../core/database/local/local_database_service.dart';
import '../models/exchange_rate_model.dart';

abstract class LocalSettingsDataSource {
  Future<List<ExchangeRateModel>> getExchangeRates();
}

class LocalSettingsDataSourceImpl implements LocalSettingsDataSource {
  LocalSettingsDataSourceImpl (this._localDatabase);

  final LocalDatabaseService _localDatabase;

  @override
  Future<List<ExchangeRateModel>> getExchangeRates() async {
    final rows = await _localDatabase.readRows(table: 'exchange_rates');

    final exchangeRates = rows.map(ExchangeRateModel.fromMap);

    return exchangeRates.toList();
  }
}
