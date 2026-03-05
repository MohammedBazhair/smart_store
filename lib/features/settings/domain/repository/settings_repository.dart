import '../../../../errors/result.dart';
import '../entities/currence_code.dart';
import '../entities/exchange_rate.dart';
import '../entities/settings.dart';

abstract class SettingsRepository {
  Future<List<ExchangeRate>> getExchangeRates();

  Future<Settings> getSettings();

  Future<void> setSettings(Settings settings);

  /// تحديث الإعدادات
  Future<Result<void>> updateSettings(Settings settings);

  Future<void> changeDefaultCurrency(CurrencyCode currence, String storeId);

}
