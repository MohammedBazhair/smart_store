import '../../../../errors/result.dart';
import '../entities/exchange_rate.dart';
import '../entities/settings.dart';

/// واجهة مستودع الإعدادات
abstract class SettingsRepository {
  Future<List<ExchangeRate>> getExchangeRates();

 Future< Settings> getSettings();

  /// تحديث الإعدادات
  Future<Result<void>> updateSettings(Settings settings);
}
