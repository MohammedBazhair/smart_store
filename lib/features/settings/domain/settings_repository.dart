import '../../../errors/result.dart';
import 'settings.dart';

/// واجهة مستودع الإعدادات
abstract class SettingsRepository {
  /// الحصول على الإعدادات
  Future<Settings> getSettings();

  /// تحديث الإعدادات
  Future<Result<void>> updateSettings(Settings settings);
}
