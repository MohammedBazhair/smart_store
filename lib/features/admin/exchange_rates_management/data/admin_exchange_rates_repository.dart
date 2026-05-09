import '../../../../core/database/remote/remote_database_service.dart';
import '../../../settings/data/datasources/remote_settings_data_source.dart';
import '../../../settings/data/models/exchange_rate_model.dart';
import '../../../settings/domain/entities/exchange_rate.dart';

class AdminExchangeRatesRepository {
  AdminExchangeRatesRepository(this._remoteSettings, this._remoteDatabase);

  final RemoteSettingsDataSource _remoteSettings;
  final RemoteDatabaseService _remoteDatabase;

  Future<List<ExchangeRate>> getAllExchangeRates() {
    return _remoteSettings.getExchangeRates();
  }

  Future<ExchangeRate> updateRateBase(ExchangeRate rate) async {
    final now = DateTime.now().toUtc();
    final updatedEntity = rate.copyWith(updatedAt: now);
    final rateModel = ExchangeRateModel.fromEntity(updatedEntity);
    await _remoteDatabase.update(
      updated: rateModel.toMapUpdate(),
      table: 'exchange_rates',
      whereFilter: {
        'currency': rate.currency.name,
      },
    );

    return updatedEntity;
  }
}
